#!/bin/bash
source config/config.conf # private variables file
source "$TEMP_VARS" # temporary variables file

######################## Terminate EC2 Instances ########################
echo "Terminating EC2 Instances..."
aws ec2 terminate-instances --instance-ids $PUBLIC_INSTANCE_ID $PRIVATE_INSTANCE_ID
echo "--> Waiting to finish..."
aws ec2 wait instance-terminated --instance-ids $PUBLIC_INSTANCE_ID $PRIVATE_INSTANCE_ID
######################## Delete Security Groups ########################
if grep -q "PRIVATE_SG_ID" "$TEMP_VARS"; then
    echo "Deleting Private Security Group..."
    aws ec2 delete-security-group --group-id $PRIVATE_SG_ID
fi
if grep -q "PUBLIC_SG_ID" "$TEMP_VARS"; then
    echo "Deleting Public Security Group..."
    aws ec2 delete-security-group --group-id $PUBLIC_SG_ID
fi
######################## Delete Subnets ########################
if grep -q "PUBLIC_SUBNET_ID" "$TEMP_VARS"; then
    echo "Deleting Public Subnet..."
    aws ec2 delete-subnet --subnet-id $PUBLIC_SUBNET_ID
    echo "Deleting Public Route Table..."
    aws ec2 delete-route-table --route-table-id $PUBLIC_ROUTE_TABLE_ID
fi
if grep -q "PRIVATE_SUBNET_ID" "$TEMP_VARS"; then
    echo "Deleting Private Subnet..."
    aws ec2 delete-subnet --subnet-id $PRIVATE_SUBNET_ID
    echo "Deleting Private Route Table..."
    aws ec2 delete-route-table --route-table-id $PRIVATE_ROUTE_TABLE_ID
fi
######################## Delete VPC peering connection ########################
if grep -q "VPC_PEER_CON_ID" "$TEMP_VARS"; then
    echo "Deleting VPC peering connection..."
    aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $VPC_PEER_CON_ID
fi
######################## Delete Internet Gateway ########################
if grep -q "IGW_ID" "$TEMP_VARS"; then
    echo "Detach Internet Gateway from VPC..."
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $NEW_VPC_ID
    echo "Deleting Internet Gateway..."
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
fi
######################## Delete new VPC ########################
if grep -q "NEW_VPC_ID" "$TEMP_VARS"; then
    echo "Deleting new VPC..."
    aws ec2 delete-vpc --vpc-id $NEW_VPC_ID
fi
######################## Clear Temporary Variables File ########################
echo "Clearing Temporary Variables File..."
> $TEMP_VARS