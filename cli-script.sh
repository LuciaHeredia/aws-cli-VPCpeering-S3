#!/bin/bash
source config.conf # Private Variables file

touch "$TEMP_VARS" # create Temporary Variables file

######################## 1. New VPC ########################
echo "Creating new VPC..."
VPC_ID=$(aws ec2 create-vpc \
        --cidr-block $VPC_CIDR_BLOCK \
        --region "$REGION" \
        --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]" \
        --query 'Vpc.VpcId' --output text)
echo "VPC_ID=$VPC_ID" > $TEMP_VARS

######################## 2. VPC Peering ########################
echo "Creating VPC peering connection..."
VPC_PEER_CON_ID=$(aws ec2 create-vpc-peering-connection \
        --vpc-id $VPC_ID --peer-vpc-id $VPC_ID_DEFAULT \
        --query 'VpcPeeringConnection.VpcPeeringConnectionId ' --output text)
echo "VPC_PEER_CON_ID=$VPC_PEER_CON_ID" >> $TEMP_VARS

echo "Accepting connection request..."
aws ec2 accept-vpc-peering-connection \
        --vpc-peering-connection-id $VPC_PEER_CON_ID

echo "Waiting for connection to be active..."
aws ec2 wait vpc-peering-connection-exists \
        --vpc-peering-connection-ids $VPC_PEER_CON_ID

echo "Deployment complete"