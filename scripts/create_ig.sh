#!/bin/bash
source config/config.conf # Private Variables file
source "$TEMP_VARS" # Temporary Variables file (IDs)

echo "Creating an Internet Gateway (for public subnet)..."
IGW_ID=$(aws ec2 create-internet-gateway \
    --region $REGION \
    --query 'InternetGateway.InternetGatewayId' --output text)

if [ -z "$IGW_ID" ]; then
    echo "--> ERROR creating Internet Gateway. Process stopped!"
    exit 1
fi

# Attach Internet Gateway to new VPC
aws ec2 attach-internet-gateway \
    --vpc-id $NEW_VPC_ID --region $REGION \
    --internet-gateway-id $IGW_ID

echo "IGW_ID=$IGW_ID" >> $TEMP_VARS
echo "--> Created and attached Internet Gateway: $IGW_ID"
