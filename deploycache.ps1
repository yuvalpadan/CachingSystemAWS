## Get Parameter for host label
Param(

   [Parameter(Mandatory=$true)]

   [string]$SName
)


# This Variable holds the given host label.
$new_host_name_v = $SName

# Test if jq command is installed.
$jq_out1 = ""
$jq_out1 = echo '{ "foo": "test"}' | jq '.foo'

# This will work only if jq command is found.
if ($jq_out1 -and $jq_out1 -eq '"test"')
{
}
else
{
    write-host "jq not install2ed"
    exit
}

# Check if the aws cli is configured.
$aws_configure = ""
$aws_configure = aws configure list | grep region

# This will work if aws is configured.
if ($aws_configure -match "region")
{
	# Get the AWS key and secret to pass to the new host so it connect to aws itself.
	$aws_acckey = aws configure get aws_access_key_id
	$aws_secrkey =  aws configure get aws_secret_access_key	
    
    
	# Create security group that allows to connect to rest api cache system (port 80- web) - If exists it passes
	aws ec2 create-security-group --group-name cachesecurgroup --description "Access the cache rest api"
	aws ec2 authorize-security-group-ingress --group-name cachesecurgroup --port 80 --protocol tcp --cidr 0.0.0.0/0
			
	# Get the created security group info.				
	$secu_group_out = aws ec2 describe-security-groups --group-names cachesecurgroup
	
	# Pull out the security group group ID if exists.
	$securenId = $secu_group_out | jq ".SecurityGroups[0].GroupId"
	
	# This will work only if the group exists.
	if ( $securenId  -ne "null")
	{
		
		# This creates a host cache node using CloudFormation script. It passes the AWS key and secret so the node call connect itself to the aws.
		aws cloudformation deploy --template-file install_hostcache.json --stack-name $new_host_name_v --parameter-overrides AccToken=$aws_acckey  SecretToken=$aws_secrkey
		
		# This waits until the node is created and running.
		aws cloudformation wait stack-create-complete --stack-name  $new_host_name_v
		
		# Fetch the new node info, if found.
		$node_out = aws ec2 describe-instances --filters Name=tag-value,Values=$new_host_name_v
		
		# Pull the instance Id of the newly created node.
		$instanId = $node_out | jq ".Reservations[0].Instances[0].InstanceId"
		
		# Pull the in which availability zone the node was created.
		$node_availb = $node_out | jq ".Reservations[0].Instances[0].Placement.AvailabilityZone"
		
		# This will work only if the node was created.
		if ( $instanId  -ne "null")
		{
			# This created the load balancer the balances between the nodes shared endpoint. It passes if exists.
			aws elb create-load-balancer --load-balancer-name yuvalloadbala --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones $node_availb
			
			# Set the load balancer to have a shared security group with all the nodes.
			aws elb apply-security-groups-to-load-balancer --load-balancer-name yuvalloadbala --security-groups $securenId
			
			# Fetch the new load balancer info, if found.
			$elb_create_out = aws elb describe-load-balancers --load-balancer-names yuvalloadbala
			
			# Pull the endpoint of the load balancer.
			$dns_name = $elb_create_out | jq  ".LoadBalancerDescriptions[0].DNSName"
			
			# This works only if the load balancer is found.
			if ( $dns_name -ne "null")
			{
				# Set the load Balancer to optimal settings to manage the balancer.
				$elb_conf_heal_out = aws elb configure-health-check --load-balancer-name yuvalloadbala --health-check Target=HTTP:80/,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3
				
				# This works only if the load balancer setup was successful.
				$heals = $elb_conf_heal_out | jq  ".HealthCheck"
				if ( $heals  -ne "null")
				{
					
					# Add the node to the load balancer.
					aws elb register-instances-with-load-balancer --load-balancer-name yuvalloadbala --instances $instanId
					
					# Set the security group of the node to match the load balancer
					aws ec2 modify-instance-attribute --instance-id $instanId --groups $securenId
					
					# This waits until the node is added to the load balancer list successfully.
					aws elb wait instance-in-service --load-balancer-name yuvalloadbala --instances $instanId
					
					# Print the load balancer URL to use the application.
					write-host "Host is accessed through the LB URL:" $dns_name
				}
				else
				{
					Write-Host "Error in LB Config " $elb_conf_heal_out
					exit
				}
			}
			else
			{
				Write-Host "Error in LB Creation " $elb_create_out
				exit
			}
		}
		else
		{
			Write-Host "Error in Instance Creation " $node_out
			exit
		}
	}
	else
	{
		Write-Host "Error in Security Group Creation " $secu_group_out
		exit
	}
    
    
    
     
}
else
{

    write-host "AWS not configured"
    exit
}
