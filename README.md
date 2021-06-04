# getsetvres

1. Configure AWS Secret key in AWSV2 CLI.


CREATE LOAD BALANCER

```
1. Create the load balancer - fill the instances availability zones.
aws elb create-load-balancer --load-balancer-name shayloadbala --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones <instance_avail_zones>


2. Setup the load balancer health check
aws elb configure-health-check --load-balancer-name <name_for_lb> --health-check Target=HTTP:80/,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3

3. use the command to get the load balancer DNS
aws elb describe-load-balancers

```


ADD ELASTIC CACHE

```
1. Creates a Redis elastic cache
aws elasticache create-cache-cluster --cache-cluster-id <name_for_cache> --cache-node-type cache.t2.micro  --engine redis      --num-cache-nodes 1


2. Wait 5 minutes for creation and then browse to the AWS portal and get the cache's endpoint

3 . Get the ConfigurationEndpoint address from the output to use when adding a node 

```


ADD HOST 

```

1. change stack-name for every new host and 
aws cloudformation deploy --template-file install_host.json --stack-name <new_host_stack_name> --parameter-overrides ElasticCacheEndPoint=<ConfigurationEndpoint>

2. Fetch the instance Id using the command:
aws ec2 describe-instances


3. Add the host instance to the load balancer
aws elb register-instances-with-load-balancer --load-balancer-name <name_for_lb> --instances <instance_id>

```


* Important - Must be Done:
	Make sure elasticache redis belongs to the security group that includes the 6379 access.
