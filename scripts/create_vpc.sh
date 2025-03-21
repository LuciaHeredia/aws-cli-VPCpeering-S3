#!/bin/bash
source config/config.conf # Private Variables file

echo "Creating VPC..."
NEW_VPC_ID=$(aws ec2 create-vpc \
        --cidr-block $NEW_VPC_CIDR_BLOCK \
        --region $REGION \
        --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$NEW_VPC_NAME}]" \
        --query 'Vpc.VpcId' --output text)

if [ -z "$NEW_VPC_ID" ]; then
    echo "--> ERROR creating VPC. Process stopped!"
    exit 1
fi

echo "NEW_VPC_ID=$NEW_VPC_ID" > $TEMP_VARS
echo "--> Created VPC: $NEW_VPC_ID"

# Enable DNS hostname support (for public subnet)
aws ec2 modify-vpc-attribute \
    --vpc-id $NEW_VPC_ID --region $REGION \
    --enable-dns-hostnames "{\"Value\":true}"
