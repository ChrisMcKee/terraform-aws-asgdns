import json
import logging
import boto3
import sys

logger = logging.getLogger()
logger.setLevel(logging.INFO)

autoscaling = boto3.client('autoscaling')
ec2 = boto3.client('ec2')
ec2r = boto3.resource('ec2')
route53 = boto3.client('route53')

HOSTNAME_TAG_NAME = "asg:hostname_pattern"

# Returns tuple (public_ips, private_ips)
def get_instances_from_autoscale_group(asgName):
    asg = autoscaling.describe_auto_scaling_groups(AutoScalingGroupNames=[asgName],MaxRecords=1)['AutoScalingGroups']

    if(len(asg) < 1): raise ValueError("No autoscale group matching name could be found")
    asg = asg[0]
    logger.info(asg['AutoScalingGroupName'])
    instance_ids = [i['InstanceId'] for i in asg['Instances']]

    running_instances = ec2r.instances.filter(InstanceIds=instance_ids)

    public_ips = [{"Value":i.public_ip_address} for i in (y for y in running_instances if y.public_ip_address is not None)]
    private_ips = [{"Value":i.private_ip_address} for i in (y for y in running_instances if y.private_ip_address is not None)]

    return  public_ips,private_ips


# Fetches relevant tags from ASG
def fetch_tag_metadata(asg_name, tagName):
    logger.info("Fetching tags for ASG: %s", asg_name)

    tag_value = autoscaling.describe_tags(
        Filters=[
            {'Name': 'auto-scaling-group','Values': [asg_name]},
            {'Name': 'key','Values': [tagName]},
        ],
        MaxRecords=1
    )['Tags'][0]['Value']

    logger.info("Found tags for ASG %s: %s", asg_name, tag_value)

    return tag_value


# Builds a hostname according to pattern
def build_hostname(hostname_pattern, cluster_name):
    return hostname_pattern.replace('#clustername', cluster_name)


# Updates a Route53 record
def update_record(zone_id, ips, hostname, operation):
    logger.info("Changing record with %s for %s -> %s in %s", operation, hostname, "", zone_id)

    route53.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={
            'Changes': [
                {
                    'Action': operation,
                    'ResourceRecordSet': {
                        'Name': hostname,
                        'Type': 'A',
                        'TTL': 30,
                        'ResourceRecords': ips
                    }
                }
            ]
        }
    )


# Processes a scaling event
# Builds a hostname from tag metadata, fetches a private IP, and updates records accordingly
def process_message(message):
    
    operation = "UPSERT"
    asg_name = message['AutoScalingGroupName']

    hostname_pattern, zone_id = fetch_tag_metadata(asg_name,HOSTNAME_TAG_NAME).split("@")
    clusterName = fetch_tag_metadata(asg_name,'cluster')

    hostname = build_hostname(hostname_pattern, clusterName)

    publicIps, privateIps = get_instances_from_autoscale_group(asg_name)

    update_record(zone_id, privateIps, hostname, operation)
    if(len(publicIps) > 0): update_record(zone_id, publicIps, "ext-"+hostname, operation)


# Picks out the message from a SNS message and deserialises it
def process_record(record):
    process_message(json.loads(record['Sns']['Message']))


# Main handler where the SNS events end up to
# Events are bulked up, so process each Record individually
def lambda_handler(event, context):
    logger.info("Processing SNS event: " + json.dumps(event))

    for record in event['Records']:
        process_record(record)


# if invoked manually, assume someone pipes in a event json
if __name__ == "__main__":
    logging.basicConfig()
    lambda_handler(json.load(sys.stdin), None)
