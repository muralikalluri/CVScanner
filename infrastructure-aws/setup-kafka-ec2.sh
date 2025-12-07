#!/bin/bash

# usage: ./setup-kafka-ec2.sh <key-pair-name>
# Prerequisite: AWS CLI configured with appropriate permissions.

KEY_NAME=$1
if [ -z "$KEY_NAME" ]; then
  echo "Usage: ./setup-kafka-ec2.sh <key-pair-name>"
  exit 1
fi

echo "Creating Security Group for Kafka..."
SG_ID=$(aws ec2 create-security-group --group-name KafkaSG --description "Security group for Kafka Broker" --output text --query 'GroupId')
echo "Security Group ID: $SG_ID"

echo "Authorizing SSH (22) and Kafka (9092)..."
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 9092 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 2181 --cidr 0.0.0.0/0 # Zookeeper

echo "Launching EC2 Instance (Amazon Linux 2023)..."
# AMI ID for Amazon Linux 2023 in us-east-1 (Change if different region)
AMI_ID="ami-0ae8f15ae66fe8cda" 

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t2.small \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --user-data file://kafka-user-data.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=CVScanner-Kafka}]' \
    --output text --query 'Instances[0].InstanceId')

echo "Instance launched: $INSTANCE_ID"
echo "Waiting for instance to run..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[0].Instances[0].PublicIpAddress')

echo "Kafka Broker deployed at: $PUBLIC_IP"
echo "Note: It may take a few minutes for Kafka to install and start."
echo "Connection String: $PUBLIC_IP:9092"
