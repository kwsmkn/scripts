#!/bin/bash

set -eu

BASE_DIR=$(cd $(dirname $0) && pwd)
source $BASE_DIR/configs/configs.sh

TODAY=`date '+%Y%m%d'`
#limit_date=`date -d "${TODAY} 1day ago" +%Y%m%d`
limit_date=`date -d "${TODAY} ${DATES}" +%Y%m%d`
instance_id=""
ami_id=""
cnt=0
i=0
j=0

## get instance_id for create ami
#instance_id=`aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAMETAG}" --query "Reservations[].Instances[].InstanceId" | jq -r .[0]`

instance_id=`aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAMETAG}" --query "Reservations[].Instances[].InstanceId" --output text`

## create ami
#ami_id=`aws ec2 create-image --instance-id ${instance_id} --name "${AMINAME}${TODAY}" --description "${AMINAME}${TODAY}" --no-reboot | jq -r .[]`

ami_id=`aws ec2 create-image --instance-id ${instance_id} --name "${AMINAME}${TODAY}" --description "${AMINAME}${TODAY}" --no-reboot --output text`

### put tags to ami
aws ec2 create-tags --resources ${ami_id} --tags Key=Name,Value=${AMINAME}${TODAY}

## copy terraform config file for backup
#cp /home/dhop/aws_terraform/configs/terraform.tfvars /home/dhop/aws_terraform/configs/terraform.tfvars.${TODAY}

cp ${CONFIG_DIR}${CONFIG_FILE} ${CONFIG_BK_DIR}${CONFIG_FILE}.${TODAY}

## rewrite ami_id
#sed -i -e "s/ami-[a-z0-9]*/${ami_id}/" /home/dhop/aws_terraform/configs/terraform.tfvars

sed -i -e "s/ami-[a-z0-9]*/${ami_id}/" ${CONFIG_DIR}${CONFIG_FILE}

## get instance_id & CreationDate for deregister ami
imgsrcs=`aws ec2 describe-images --owner ${OWNER_ID} --filter "Name=name, Values=${AMINAME}*" --query 'reverse(sort_by(Images,&CreationDate))' --query 'Images[].[ImageId,CreationDate]' --output text`

## get snapshot_id for delete snapshot
imgsrcs_snap=`aws ec2 describe-images --owner ${OWNER_ID} --filter "Name=name, Values=${AMINAME}*" --query 'Images[].[ImageId,CreationDate]'  --query 'Images[].BlockDeviceMappings[].Ebs[].SnapshotId' --output text`

## put return values to arrays
img=($imgsrcs)
snaps=($imgsrcs_snap)

## get a loop count
cnt=`expr "${#img[@]}" - 1`

if [ $cnt -lt 1  ]; then
  exit 0
fi

## deresister amis & delete snapshots
for x in `seq 0 "${cnt}"`; 
do 
if [ `expr $x % 2` != 0 ] ; then
  creation_dates[$i]=`date -d ${img[$x]} +%Y%m%d`
  if [ ${creation_dates[$i]} -le ${limit_date} ] ; then
    j=`expr $x - 1`
    aws ec2 deregister-image --image-id ${img[$j]}
    aws ec2 delete-snapshot --snapshot-id ${snaps[$i]}
  fi
  i=$((i+1))
fi 
done

exit 0
