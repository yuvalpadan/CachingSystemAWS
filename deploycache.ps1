Param(

   [Parameter(Mandatory=$true)]

   [string]$SName


)



$new_host_name_v = $SName

$jq_out1 = ""
$jq_out1 = echo '{ "foo": "test"}' | jq '.foo'
if ($jq_out1 -and $jq_out1 -eq '"test"')
{
}
else
{
    write-host "jq not install2ed"
    exit
}
$aws_configure = ""
$aws_configure = aws configure list | grep region
if ($aws_configure -match "region")
{
	$aws_acckey = aws configure get aws_access_key_id
	$aws_secrkey =  aws configure get aws_secret_access_key	
    
    
	
	aws ec2 create-security-group --group-name yuvalsecurgroup --description "Access the parking lot instances"
	aws ec2 authorize-security-group-ingress --group-name yuvalsecurgroup --port 80 --protocol tcp --cidr 0.0.0.0/0
			
					
	$secu_group_out = aws ec2 describe-security-groups --group-names yuvalsecurgroup
	$securenId = $secu_group_out | jq ".SecurityGroups[0].GroupId"
	if ( $securenId  -ne "null")
	{
		aws cloudformation deploy --template-file install_hostcache.json --stack-name $new_host_name_v --parameter-overrides AccToken=$aws_acckey  SecretToken=$aws_secrkey
		aws cloudformation wait stack-create-complete --stack-name  $new_host_name_v
		$node_out = aws ec2 describe-instances --filters Name=tag-value,Values=$new_host_name_v
		$instanId = $node_out | jq ".Reservations[0].Instances[0].InstanceId"
		$node_availb = $node_out | jq ".Reservations[0].Instances[0].Placement.AvailabilityZone"
		if ( $instanId  -ne "null")
		{
			aws elb create-load-balancer --load-balancer-name yuvalloadbala --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones $node_availb
			aws elb apply-security-groups-to-load-balancer --load-balancer-name yuvalloadbala --security-groups $securenId
			$elb_create_out = aws elb describe-load-balancers --load-balancer-names yuvalloadbala
			$dns_name = $elb_create_out | jq  ".LoadBalancerDescriptions[0].DNSName"
			
			if ( $dns_name -ne "null")
			{
				$elb_conf_heal_out = aws elb configure-health-check --load-balancer-name yuvalloadbala --health-check Target=HTTP:80/,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3
				$heals = $elb_conf_heal_out | jq  ".HealthCheck"
				if ( $heals  -ne "null")
				{
					aws elb register-instances-with-load-balancer --load-balancer-name yuvalloadbala --instances $instanId
					
					aws ec2 modify-instance-attribute --instance-id $instanId --groups $securenId
					aws elb wait instance-in-service --load-balancer-name yuvalloadbala --instances $instanId
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