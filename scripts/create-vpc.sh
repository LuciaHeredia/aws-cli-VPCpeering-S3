#!/bin/bash
source config/config.conf # Private Variables file

echo "Creating new VPC..."
NEW_VPC_ID=$(aws ec2 create-vpc \
        --cidr-block $NEW_VPC_CIDR_BLOCK \
        --region $REGION \
        --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$NEW_VPC_NAME}]" \
        --query 'Vpc.VpcId' --output text)
echo "NEW_VPC_ID=$NEW_VPC_ID" > $TEMP_VARS
echo "--> Created new VPC: $NEW_VPC_ID"
