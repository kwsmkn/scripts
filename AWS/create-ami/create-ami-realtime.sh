#!/bin/bash

set -eu

BASE_DIR=$(cd $(dirname $0) && pwd)

source $BASE_DIR/configs/configs.sh

TODAY=`date '+%Y%m%d'`
instance_ids=""
instance_names=""
source_ids=""
source_names=""
j=0

## get instance_ids (only status is 'running' and tag-key=Name)
instance_ids=`aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag-key,Values=Name" --query "Reservations[].Instances[].InstanceId" --output text`

## get instance_Name (only status is 'running' and tag-key=Name)
instance_names=`aws ec2 describe-instances --instance-ids ${instance_ids} --filters "Name=tag-key,Values=Name" --query "Reservations[].Instances[].Tags[].Value" --output text`

source_ids=($instance_ids)
source_names=($instance_names)

for i in "${source_ids[@]}"
do
  ami_id=""
  
  ## create ami
  ami_id=`aws ec2 create-image --instance-id ${i} --name "${source_names[$j]}-${TODAY}" --description "${source_names[$j]}-${TODAY}" --no-reboot --output text`

  ### put tags to ami
  aws ec2 create-tags --resources ${ami_id} --tags Key=Name,Value="${source_names[$j]}-${TODAY}"
  j=$((j+1))
done

exit 0
