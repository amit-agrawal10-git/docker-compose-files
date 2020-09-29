#!/bin/bash

# Start JMS Instance
JMS_INSTANCE_ID=i-02ea0fc6bd64934ce
COMMON_SERVICE=i-0afad1b136c8c403a
INVENTORY_SERVICE=i-0f63d500ecc9f4b88
BEER_ORDER_SERVICE=i-04970686c9589452b
DB_INSTANCE_ID=micro-beer-service-db

#Stop BEER Order Service
echo Stop Beer Order docker service
#Grep public IP 
BEER_ORDER_SERVICE_IP=`aws ec2 describe-instances --instance-ids $BEER_ORDER_SERVICE --output text --query 'Reservations[].Instances[].[PublicIpAddress]'`
echo Beer Order Service IP is $BEER_ORDER_SERVICE_IP

./stopDockerInstance.sh $BEER_ORDER_SERVICE $BEER_ORDER_SERVICE_IP

#Stop Inventory Service
echo Stop Inventory docker service
#Grep public IP 
INVENTORY_SERVICE_IP=`aws ec2 describe-instances --instance-ids $INVENTORY_SERVICE --output text --query 'Reservations[].Instances[].[PublicIpAddress]'`
echo Inventory Service IP is $INVENTORY_SERVICE_IP

./stopDockerInstance.sh $INVENTORY_SERVICE $INVENTORY_SERVICE_IP

#Stop Common Service
echo Stop Common docker service
#Grep public IP 
COMMON_SERVICE_IP=`aws ec2 describe-instances --instance-ids $COMMON_SERVICE --output text --query 'Reservations[].Instances[].[PublicIpAddress]'`
echo Common Service IP is $COMMON_SERVICE_IP

./stopDockerInstance.sh $COMMON_SERVICE $COMMON_SERVICE_IP

#Stop Common Service
echo Stop JMS and ZIPKIN docker service
#Grep public IP 
JMS_SERVER_IP=`aws ec2 describe-instances --instance-ids $JMS_INSTANCE_ID --output text --query 'Reservations[].Instances[].[PublicIpAddress]'`
echo JMS Server IP is $JMS_SERVER_IP

./stopDockerInstance.sh $JMS_INSTANCE_ID $JMS_SERVER_IP

echo sleep for 60 seconds 
sleep 60 

echo stop ec2 instance

aws ec2 stop-instances --instance-ids $BEER_ORDER_SERVICE
aws ec2 stop-instances --instance-ids $INVENTORY_SERVICE
aws ec2 stop-instances --instance-ids $COMMON_SERVICE
aws ec2 stop-instances --instance-ids $JMS_INSTANCE_ID
