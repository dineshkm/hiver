import boto3
from tabulate import tabulate

client = boto3.client('ec2',region_name="us-east-1")

response = client.describe_instances(
    Filters=[
        {
            'Name': 'instance-type',
            'Values': [
                'm5.large',
            ]
        },
    ]
)

instance_details = []
for reservation in response['Reservations']:
    instances = reservation['Instances']
    for instance in instances:
        tags = instance["Tags"]
        for tag in tags:
            if tag['Key'] == 'Name':
                instance_details.append([tag['Value'],instance['InstanceId']])                                

print(tabulate(instance_details, headers=['Name Tag', 'Instance ID']))