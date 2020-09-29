#!/bin/bash

# Start DB Instance

INSTANCE_ID=$1

CURRENT_STATE=`aws rds describe-db-instances --db-instance-identifier $INSTANCE_ID --output text --query 'DBInstances[].[DBInstanceStatus]'`

echo Current State $CURRENT_STATE

#Verify that instance is running 
times=20
echo
while [[ 0 -lt $times && $CURRENT_STATE != "available" ]]
do
  times=$(( $times - 1 ))
  echo Current DB State $CURRENT_STATE
  echo Remaining attempt $times to verify $INSTANCE_ID is available...
  echo Sleeping for 10 seconds
  sleep 10
  CURRENT_STATE=`aws rds describe-db-instances --db-instance-identifier $INSTANCE_ID --output text --query 'DBInstances[].[DBInstanceStatus]'`
done

if [ 0 -eq $times ]; then
  echo Instance $INSTANCE_ID is not running. Exiting...
  exit
elif [ 20 -ne $times ]; then
	echo Sleeping for 20 seconds before connect
	sleep 20
else 
	echo Connecting to DB
fi