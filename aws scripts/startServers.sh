#!/bin/bash

# Start JMS Instance
JMS_INSTANCE_ID=i-02ea0fc6bd64934ce
COMMON_SERVICE=i-0afad1b136c8c403a
INVENTORY_SERVICE=i-0f63d500ecc9f4b88
BEER_ORDER_SERVICE=i-04970686c9589452b
DB_INSTANCE_ID=micro-beer-service-db

CURRENT_STATE=`aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_ID --output text --query 'DBInstances[].[DBInstanceStatus]'`

if [ $CURRENT_STATE != "available" ]; then
  echo Instance $DB_INSTANCE_ID is not running. starting the instance...
  aws rds start-db-instance --db-instance-identifier $DB_INSTANCE_ID
else 
  echo DB is up and running
fi

./startInstance.sh $JMS_INSTANCE_ID

#Grep public IP 
JMS_SERVER_IP=`aws ec2 describe-instances --instance-ids $JMS_INSTANCE_ID --output text --query 'Reservations[].Instances[].[PublicIpAddress]'`

echo JMS Server IP is $JMS_SERVER_IP

#Connect 
ssh -i defaultkp.pem -o StrictHostKeyChecking=no ec2-user@$JMS_SERVER_IP -t "sudo docker-compose -f common-compose.yaml up -d"

echo sleep for 30 seconds

sleep 30

#Start Common Service
echo Start common service
./startInstance.sh $COMMON_SERVICE

#Grep public IP 
COMMON_SERVICE_IP=`aws ec2 describe-instances --instance-ids $COMMON_SERVICE --output text --query 'Reservations[].Instances[].[PublicIpAddress]'`

echo Common Service IP is $COMMON_SERVICE_IP

#Connect 
ssh -i defaultkp.pem -o StrictHostKeyChecking=no ec2-user@$COMMON_SERVICE_IP -t "sudo MACHINE_IP_ADDRESS=$COMMON_SERVICE_IP ZIPKIN_IP_ADDRESS=$JMS_SERVER_IP docker-compose -f common-compose.yaml up -d"


# Start DB Instance
echo checking if DB is up and available
./startDBInstance.sh $DB_INSTANCE_ID

#Start Inventory Service
echo Start Inventory service
./startInstance.sh $INVENTORY_SERVICE

#Grep public IP 
INVENTORY_SERVICE_IP=`aws ec2 describe-instances --instance-ids $INVENTORY_SERVICE --output text --query 'Reservations[].Instances[].[PublicIpAddress]'`

echo Inventory Service IP is $INVENTORY_SERVICE_IP

#Connect 
ssh -i defaultkp.pem -o StrictHostKeyChecking=no ec2-user@$INVENTORY_SERVICE_IP -t "sudo MACHINE_IP_ADDRESS=$INVENTORY_SERVICE_IP ZIPKIN_IP_ADDRESS=$JMS_SERVER_IP EUREKA_IP_ADDRESS=$COMMON_SERVICE_IP JMS_IP_ADDRESS=$JMS_SERVER_IP docker-compose -f common-compose.yaml up -d"

#Start BEER Order Service
echo Start Beer Order service
./startInstance.sh $BEER_ORDER_SERVICE

#Grep public IP 
BEER_ORDER_SERVICE_IP=`aws ec2 describe-instances --instance-ids $BEER_ORDER_SERVICE --output text --query 'Reservations[].Instances[].[PublicIpAddress]'`

echo Beer Order Service IP is $BEER_ORDER_SERVICE_IP

#Connect 
ssh -i defaultkp.pem -o StrictHostKeyChecking=no ec2-user@$BEER_ORDER_SERVICE_IP -t "sudo MACHINE_IP_ADDRESS=$BEER_ORDER_SERVICE_IP ZIPKIN_IP_ADDRESS=$JMS_SERVER_IP EUREKA_IP_ADDRESS=$COMMON_SERVICE_IP JMS_IP_ADDRESS=$JMS_SERVER_IP INVENTORY_IP_ADDRESS=$INVENTORY_SERVICE_IP docker-compose -f common-compose.yaml up -d"
