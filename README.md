# getsetvres

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



