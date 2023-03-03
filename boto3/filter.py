import boto3

client =boto3.client('ec2',
        region_name = 'us-east-1',
        aws_access_key_id = '',
        aws_secret_access_key = '')

# Create boto3 ec2 resource
ec2 = boto3.resource('ec2')

# Retrieve instances with a name tag that contains Webserver
filters = [{'Name':'tag:', 'Values': ['Wordpress*']}]

instances = ec2.instances.filter(Filters=filters)

# For each insteance with a tag
for i in instances:
    for tag in i.tags:
        if tag['Key'] == 'Name':
            instanceName = tag['Value']
            print(instanceName)
