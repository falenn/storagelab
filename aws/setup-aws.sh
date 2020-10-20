#!/bin/bash
tags="Key=lab,Value=storage"
account=357531561252
terraformbucket="storagelab2"
mode="create"
user="storagelab"
group="labs"
profile="storagelab"
#role="storagelabrole"
#rolepolicyfile="file://storagelab-role-policy.json"
policy="storagelab"
policyfile="file://storagelab-policy-relaxed.json"

#default mode
mode="create"

while getopts "m:" arg; do
  case $arg in
    m)
      mode=$OPTARG
      ;;
  esac
done

echo "Mode: $mode"

if [[ "$mode" == "deleteUser" ]]; then
  echo "Deleting $user"
  aws iam list-access-keys --user-name $user
  echo "Delete the access keys (in a different shell) using aws iam delete-access-key --user-name $user --access-key-id <ID>."
  read -p "Press enter to continue"
  aws iam remove-user-from-group --user-name $user --group-name $group
  aws iam delete-user --user-name $user
fi

if [[ "$mode" == "delete" ]]; then
  echo "Deleting Resources"
  aws s3api delete-bucket --bucket $terraformbucket
  aws iam detach-group-policy --group-name $group \
	--policy-arn arn:aws:iam::$account:policy/$policy
  aws iam remove-user-from-group --group-name $group --user-name $user
  aws iam delete-group --group-name $group
  aws iam delete-policy --policy-arn arn:aws:iam::$acocunt:policy/$policy
fi

if [[ "$mode" == "create" ]]; then
  echo "Creating resources"
  aws iam get-policy --policy-arn arn:aws:iam::$account:policy/$policy
  if [[ $? != 0 ]]; then
    echo "Creating policy $policy"
    aws iam create-policy --policy-name $policy \
        --policy-document $policyfile
  fi
  
  # Create Group
  aws iam get-group --group-name $group
  if [[ $? != 0 ]]; then
    echo "Creating group $group"
    aws iam create-group --group-name $group
    aws iam attach-group-policy --group-name $group \
	--policy-arn arn:aws:iam::$account:policy/$policy
  fi


  # create IAM user for storagelab
  aws iam get-user --user-name $user
  if [[ $? != 0 ]]; then
    echo "Creating user $user"
    aws iam create-user --user-name $user \
        --tags $tags
    access_and_secret_key=`aws iam create-access-key --user-name $user`
    echo "$access_and_secret_key" >> access_and_secret.json
  fi
  # Always do these
  aws iam add-user-to-group --group-name $group --user-name $user
  echo "Listing user and attached policies"
  aws iam list-attached-user-policies --user-name $user
fi

if [[ "$mode" == "createS3" ]]; then
  # create s3 bucket for terraform state 
  out=`aws s3api get-bucket-acl --bucket $terraformbucket \
	--profile $profile`
  if [[ $out != *$terraformbucket* ]]; then
    echo "Creating s3 bucket $terraformbucket"
    aws s3api create-bucket --bucket $terraformbucket
  fi
fi

