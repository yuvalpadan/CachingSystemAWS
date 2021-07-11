instfirst=`aws elb describe-load-balancers --load-balancer-name yuvalloadbala |  jq ".LoadBalancerDescriptions[0].Instances[0].InstanceId"`
instfirst=`echo "$instfirst" | tr -d '"'`
instdns=`aws ec2 describe-instances --instance-ids $instfirst |  jq ".Reservations[0].Instances[0].PublicDnsName"`
instdns=`echo "$instdns" | tr -d '"'`
if [[ $instdns == *"ec2"* ]]; then
  getCacheURL="http://${instdns}/cachefile.dbcache"
	wget $getCacheURL -O /var/www/html/cachefile.dbcache
fi
