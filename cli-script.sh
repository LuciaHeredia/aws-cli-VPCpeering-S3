#!/bin/bash
source config.conf # Private Variables file

######################## Local Variables ########################




touch "$TEMP_VARS" # create Temporary Variables file

######################## 1. VPC ########################
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
        --cidr-block $VPC_CIDR_BLOCK \
        --region "$REGION" \
        --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value="$VPC_NAME"]" \
        --query 'Vpc.VpcId' --output text)
echo "VPC_ID=$VPC_ID" > $TEMP_VARS

echo "Deployment complete"