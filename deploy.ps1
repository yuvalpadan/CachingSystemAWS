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
    aws elasticache create-cache-cluster --cache-cluster-id yuvalredischachv --cache-node-type cache.t2.micro  --engine redis      --num-cache-nodes 1
    aws elasticache wait cache-cluster-available --cache-cluster-id yuvalredischachv --show-cache-node-info
    $elstic_cache_out = aws elasticache describe-cache-clusters --show-cache-node-info  --cache-cluster-id yuvalredischachv
    $elstic_cache_availb = $elstic_cache_out | jq ".CacheClusters[0].PreferredAvailabilityZone"
    $endpoi = $elstic_cache_out | jq ".CacheClusters[0].CacheNodes[0].Endpoint.Address"
    if ( $endpoi  -ne "null")
    {
                
                
        aws ec2 create-security-group --group-name yuvalsecurgroup --description "Access the parking lot instances"
        aws ec2 authorize-security-group-ingress --group-name yuvalsecurgroup --port 80 --protocol tcp --cidr 0.0.0.0/0
        aws ec2 authorize-security-group-ingress --group-name yuvalsecurgroup --port 6379 --protocol tcp --cidr 0.0.0.0/0
                
                
        $secu_group_out = aws ec2 describe-security-groups --group-names yuvalsecurgroup
        $securenId = $secu_group_out | jq ".SecurityGroups[0].GroupId"
        if ( $securenId  -ne "null")
        {
            aws cloudformation deploy --template-file install_host.json --stack-name $new_host_name_v --parameter-overrides ElasticCacheEndPoint=$endpoi
            $node_out = aws ec2 describe-instances --filters Name=tag-value,Values=$new_host_name_v
            $instanId = $node_out | jq ".Reservations[0].Instances[0].InstanceId"
            $node_availb = $node_out | jq ".Reservations[0].Instances[0].Placement.AvailabilityZone"
            if ( $instanId  -ne "null")
            {
                aws elb create-load-balancer --load-balancer-name yuvalloadbala --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones $elstic_cache_availb
                aws elb enable-availability-zones-for-load-balancer --load-balancer-name yuvalloadbala --availability-zones $node_availb
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
                        aws elasticache modify-cache-cluster --cache-cluster-id yuvalredischachv --security-group-ids $securenId
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
        Write-Host "Error in Elastic Cache Creation " $elstic_cache_out
        exit
    }
    
     
}
else
{

    write-host "AWS not configured"
    exit
}