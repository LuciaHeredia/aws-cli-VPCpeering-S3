#!/bin/bash
source config/config.conf # Private Variables file
source "$TEMP_VARS" # Temporary Variables file

echo "Creating Public Subnet..."
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $NEW_VPC_ID --region $REGION \
    --cidr-block $PUBLIC_SUBNET_CIDR \
    --query 'Subnet.SubnetId' --output text)
echo "PUBLIC_SUBNET_ID=$PUBLIC_SUBNET_ID" > $TEMP_VARS
echo "--> Created Public Subnet: $PUBLIC_SUBNET_ID"

echo "Creating a route table for the public subnet..."
PUBLIC_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
    --vpc-id $NEW_VPC_ID --region $REGION \
    --query 'RouteTable.RouteTableId' --output text)
aws ec2 associate-route-table \
    --region $REGION \
    --route-table-id $PUBLIC_ROUTE_TABLE_ID \
    --subnet-id $PUBLIC_SUBNET_ID
aws ec2 create-route \
    --route-table-id $PUBLIC_ROUTE_TABLE_ID \
    --destination-cidr-block "0.0.0.0/0" \
    --gateway-id $IGW_ID --region $REGION
echo "PUBLIC_ROUTE_TABLE_ID=$PUBLIC_ROUTE_TABLE_ID" > $TEMP_VARS
echo "--> Created and associated Public Route Table: $PUBLIC_ROUTE_TABLE_ID"
#######
echo "Creating Private Subnet..."
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $NEW_VPC_ID --region $REGION \
    --cidr-block $PRIVATE_SUBNET_CIDR \
    --query 'Subnet.SubnetId' --output text)
echo "PRIVATE_SUBNET_ID=$PRIVATE_SUBNET_ID" > $TEMP_VARS
echo "--> Created Private Subnet: $PRIVATE_SUBNET_ID"

echo "Creating a route table for the private subnet..."
PRIVATE_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
    --vpc-id $NEW_VPC_ID text --region $REGION \
    --query 'RouteTable.RouteTableId' --output)
aws ec2 associate-route-table \
    --region $REGION \
    --route-table-id $PRIVATE_ROUTE_TABLE_ID \
    --subnet-id $PRIVATE_SUBNET_ID
echo "PRIVATE_ROUTE_TABLE_ID=$PRIVATE_ROUTE_TABLE_ID" > $TEMP_VARS
echo "--> Created and associated Private Route Table: $PRIVATE_ROUTE_TABLE_ID"
