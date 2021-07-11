# Load the AWS environment variables in order to connect to the AWS environemnt.
set -a; source /etc/environment ; set +a;

# Get the instances registered in the load balancer.
insts=`aws elb describe-load-balancers --load-balancer-name yuvalloadbala |  jq ".LoadBalancerDescriptions[0].Instances[].InstanceId"`

# For each Instance
for instance in $insts; do
	# GFormat the Instance ID correctly.
	theinst=`echo "$instance" | tr -d '"'`
	
	# Pull the DNS assigned to the instance.
	instdns=`aws ec2 describe-instances --instance-ids $theinst |  jq ".Reservations[0].Instances[0].PublicDnsName"`
	
	# Format the DNS correctly.
	instdns=`echo $instdns | tr -d '"'`
	
	# Print the DNS.
	echo $instdns
done
