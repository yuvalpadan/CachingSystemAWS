# CachingSystemAWS

A caching system to store users’ session data.
The session data is addressable by key (the user id) and can range in size between
0.5 KB – 8 KB of data.
The code should be deployed and ran on an AWS EC2 instance.


Configure AWS Secret key in AWSV2 CLI.


Run this command to Create a Node and Add to the LB.
This can executed multiple times to add different nodes:
```
powershell -file deploy.ps1 -SName <NodeName>

```
