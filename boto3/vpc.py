import boto3
client =boto3.client('ec2',
        region_name = 'us-east-2',
        aws_access_key_id = '',
        aws_secret_access_key = '')


myvpc = client.create_vpc(
        #CidrBlock='10.10.0.0/16',
        CidrBlock= input('Enter the Cidr for Vpc:'),
        TagSpecifications=[
            {
                'ResourceType' : 'vpc',
                'Tags':[
                    {                      
                        'Key':'Name',
                        'Value' : input('enter thevpc name:') 
                        #'Value':'boto3vpc'
                    }                         
                ]
            } 
        ]     
 )


print(myvpc['Vpc']['VpcId'])

mysubnet1 = client.create_subnet(
        CidrBlock='10.0.1.0/24',
        AvailabilityZone = 'us-east-2a',
        VpcId = myvpc['Vpc']['VpcId'],
        TagSpecifications=[
            {
                'ResourceType' : 'subnet',
                'Tags':[
                    {
                        'Key':'Name',
                        'Value':'boto3subnet1'
                    }
                ]
            }
        ]
 )


print(mysubnet1['Subnet']['SubnetId'])

mysubnet2 = client.create_subnet(
        CidrBlock='10.0.2.0/24',
        AvailabilityZone = 'us-east-2b',
        VpcId = myvpc['Vpc']['VpcId'],
        TagSpecifications=[
            {
                'ResourceType' : 'subnet',
                'Tags':[
                    {
                        'Key':'Name',
                        'Value':'boto3subnet2'
                    }
                ]
            }
        ]
 )

print(mysubnet2['Subnet']['SubnetId'])


myroutetable = client.create_route_table(
        VpcId = myvpc['Vpc']['VpcId'],
        TagSpecifications=[
            {
                'ResourceType' : 'route-table',
                'Tags':[
                    {
                        'Key':'Name',
                        'Value':'boto3pubrt'
                    }
                ]
            }
        ]
 )

print(myroutetable['RouteTable']['RouteTableId'])

myigw = client.create_internet_gateway(
        TagSpecifications=[
            {
                'ResourceType' : 'internet-gateway',
                'Tags':[
                    {
                        'Key':'Name',
                        'Value':'boto3igw'
                    }
                ]
            }
        ]
 )

print(myigw['InternetGateway']['InternetGatewayId'])

attachigw = client.attach_internet_gateway(
        InternetGatewayId = myigw['InternetGateway']['InternetGatewayId'],
        VpcId = myvpc['Vpc']['VpcId']
        )
print('Attached IGW')

addroute = client.create_route(
        DestinationCidrBlock = '0.0.0.0/0',
        RouteTableId = myroutetable['RouteTable']['RouteTableId'],
        GatewayId =  myigw['InternetGateway']['InternetGatewayId'])
print('Added route to the table')

assocsubnet = client.associate_route_table(
        RouteTableId = myroutetable['RouteTable']['RouteTableId'],
        SubnetId = mysubnet1['Subnet']['SubnetId'])

print('All done')

