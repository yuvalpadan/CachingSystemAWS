# getsetvres

This is cache user session management system. The system is used through the get and put endpoints. The insert data function is used with the put endpoint by sending key, data (between 0.5KB-8KB), and expire data. The fetch data function is used with the get endpoint and requires the key info. You can find more information below in the Insert Data/Pull Data section.  When you insert an item through the load balancer enpoint, an added item reaches one of the nodes in the load balancer. When it reaches the node it then the node executes the aws command in a script to get all the nodes in the load balancer group. With the list of the nodes in the load balancer group, the node sends a request to each one of nodes through a different endpoint update that adds the item to the data file on that node in order to sync the data files between the nodes.

Files:
```
deploycache.ps1 - This script creates the security group, load balancer, and the node to be added if they don't exist.

get.php - This PHP Web file script that is used to get the data that corresponds to an exising key.

getUpdatedCache.sh - This script run inital on the node to get the Updated cache data file.

install_hostcache.json - This cloudformation script created the host cache node.

listDNSCacheInstances.sh - This script is used with the put.php script to list all the nodes in the load balancer group to sync the data file.

put.php - This PHP Web file script is used to accept data to add and then fetches a list of the nodes in the load balancer. With the list, the script sends a request to each one to sync the files on all the nodes with the new data.

update.php - This PHP Web file script is called by put.php when adding a new item to the cache system. The script writes the new data to the cache save data file.

```

1. Configure AWS Secret key in AWSV2 CLI.

2. Make sure you have the utility jq installed.
For Windows:
```
Install by running the command:
chocolatey install jq
```


Run this command to Create a Node and Add to the LB.
This can executed multiple times to add different nodes:
```
powershell -file deploycache.ps1 -SName <NodeName>
```
The script will output the URL of the LB.

You can test the API through PostMan:
For Example:

Insert Data:

POST URL: <LB_URL>/put.php

Body-> Raw:
Body:
```
{
  "str_key": "test123",
  "data": "testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestttesttesttesttesttesttesttesttesttesttesttesttesttestesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestttesttesttesttesttesttesttesttesttesttesttesttesttestesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest",
  "expiration_date": "31-06-2021"
}
```

Pull Data:

POST URL: <LB_URL>/get.php

Body-> Raw:
Body:
```
{
  "str_key": "test123"
}
```




