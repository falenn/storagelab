# AWSCLI Usage
Don't forget to install jq - for json parsing
sudo yum install -y jq
##AWSCLI notes
https://medium.com/circuitpeople/aws-cli-with-jq-and-bash-9d54e2eabaf1
https://cloudonaut.io/6-tips-and-tricks-for-aws-command-line-ninjas/

##Policy
```
aws iam create-policy --policy-name storagelab-strict --policy-document file://storagelab-policy-strict.json --tags Key=lab,value=storage
```
This command creates a policy and yields an ARN for it:  arn:aws:iam::357531561252:policy/storagelab-strict
Get the policy
```
aws iam list-policies
```
Delete policy
```
aws iam delete-policy --policy-arn arn:aws:iam::357531561252/storagelab-strict
```

##IAM user
Create
```
aws iam create-user --user-name storagelab --permissions-boundary arn:aws:iam::357531561252:policy/storagelab-strict --tags Key=lab,Value=storage
```
Delete
```
aws iam delete-user --user-arn arn:aws:iam::357531561252:user/storagelab
```


