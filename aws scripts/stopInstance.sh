#!/bin/bash

# Start Instance

INSTANCE_ID=$1
INSTANCE_ADDR=$2

CURRENT_STATE=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[].Instances[].State[].[Name]'`

echo Current State $CURRENT_STATE

if [ $CURRENT_STATE == "running" ]; then
  echo Trying to stop docker service
  ssh -i defaultkp.pem -o StrictHostKeyChecking=no ec2-user@$2 -t "sudo docker-compose -f common-compose.yaml down --remove-orphans"
else 
	echo Server is not running
fi