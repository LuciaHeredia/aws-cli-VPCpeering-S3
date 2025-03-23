#!/bin/bash
source config/config.conf # Private Variables file
source "$TEMP_VARS" # Temporary Variables file (IDs)

echo "Creating a Security Group for Public Instance..."
PUBLIC_SG_ID=$(aws ec2 create-security-group \
    --group-name "PublicInstanceSG" --description "SG for public EC2 instance" \
    --vpc-id $NEW_VPC_ID --region $REGION \
    --query 'GroupId' --output text)
# allows SSH from anywhere
aws ec2 authorize-security-group-ingress \
    --group-id $PUBLIC_SG_ID --region $REGION \
    --protocol tcp --port 22 --cidr 0.0.0.0/0
echo "PUBLIC_SG_ID=$PUBLIC_SG_ID" >> $TEMP_VARS
echo "--> Created Security Group for Public Instance: $PUBLIC_SG_ID"

echo "Creating a Security Group for Private Instance..."
PRIVATE_SG_ID=$(aws ec2 create-security-group \
    --group-name "PrivateInstanceSG" --description "SG for private EC2 instance" \
    --vpc-id $NEW_VPC_ID --region $REGION \
    --query 'GroupId' --output text)
# allows SSH only from public instance
aws ec2 authorize-security-group-ingress \
    --group-id $PRIVATE_SG_ID --region $REGION \
    --protocol tcp --port 22 --source-group $PUBLIC_SG_ID
echo "PRIVATE_SG_ID=$PRIVATE_SG_ID" >> $TEMP_VARS
echo "--> Created Security Group for Private Instance: $PRIVATE_SG_ID"
