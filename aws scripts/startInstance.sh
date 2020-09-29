#!/bin/bash

# Start Instance

INSTANCE_ID=$1

aws ec2 start-instances --instance-ids $INSTANCE_ID

CURRENT_STATE=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[].Instances[].State[].[Name]'`

echo Current State $CURRENT_STATE

#Verify that instance is running 
times=10
echo
while [[ 0 -lt $times && $CURRENT_STATE != "running" ]]
do
  times=$(( $times - 1 ))
  echo Attempt at verifying $INSTANCE_ID is running...
  echo Sleeping for 5 seconds
  sleep 5
  CURRENT_STATE=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[].Instances[].State[].[Name]'`
done

if [ 0 -eq $times ]; then
  echo Instance $INSTANCE_ID is not running. Exiting...
  exit
elif [ 10 -ne $times ]; then
	echo Sleeping for 20 seconds before connect
	sleep 20
else 
	echo Connecting to server
fi