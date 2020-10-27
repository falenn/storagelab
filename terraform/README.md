# terraform init
initializes working directory
must be ran at least once
configures backend for storing state, doesn't modify or delete any current state

# terraform fmt (format)
makes terraform templates easy to read
safe to run any time

# terraform vlaidate
must have had init run first
validates config files
safe to run at any time

# terraform plan
calculates state delta
```
terraform plan -out plan.out
```
Does save any credentials to plain-text, but does save time prior to executing apply

# terraform apply
applies changes suggested by execution plan
You can supply the "plan" file

# Persist terraform state to S3
This keeps it safe and encrypted!
## Create S3 bucket
```
aws s3api create-bucket --bucket storageclass/terraformstatebucket
```

If you change the bucket name, you may need to delete the .terraform local metadata file to connect to the new bucket.


Ready?
```
terraform init # create .terraform data for state management
terraform fmt  # clean it up
terraform validate 
terraform plan -out plan.tf # plan the state change and save the steps
terraform apply "plan.tf"   # apply the changes!

Now, when we are done, we can clean up...
terraform destroy
```

```
aws ec2 describe-vpcs
aws ec2 describe-availability-zones

SSM AMI
Systems Manager - ReST endpoint for getting latest AWS AMI ID
This will fetch and save into a variable the AMI id for the current image.  We can see this value if we fetch the terraform state from S3 and look for the SSM section.


# SSH key creation for SSH access
on our local machine,
```
ssh-keygen -t rsa -b 2048 
...
```
When uploading ssh keys for ssh access to ec2 nodes, remember, ssh key storge is regional, so we have to place a public key in each region.

User_data
/var/log/cloud-init-output.log for debug


