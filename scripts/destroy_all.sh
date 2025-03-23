#!/bin/bash
source config/config.conf # private variables file
source "$TEMP_VARS" # temporary variables file (IDs)

######################## Terminate EC2 Instances ########################
if grep -q "PUBLIC_INSTANCE_ID" "$TEMP_VARS" && grep -q "PRIVATE_INSTANCE_ID" "$TEMP_VARS"; then
    echo "Terminating EC2 Instances: $PUBLIC_INSTANCE_ID, $PRIVATE_INSTANCE_ID ..."
    aws ec2 terminate-instances --instance-ids $PUBLIC_INSTANCE_ID $PRIVATE_INSTANCE_ID
    echo "--> Waiting to finish..."
    aws ec2 wait instance-terminated --instance-ids $PUBLIC_INSTANCE_ID $PRIVATE_INSTANCE_ID
fi
######################## Delete Security Groups ########################
if grep -q "PRIVATE_SG_ID" "$TEMP_VARS"; then
    echo "Deleting Private Security Group: $PRIVATE_SG_ID ..."
    aws ec2 delete-security-group --group-id $PRIVATE_SG_ID
fi
if grep -q "PUBLIC_SG_ID" "$TEMP_VARS"; then
    echo "Deleting Public Security Group: $PUBLIC_SG_ID ..."
    aws ec2 delete-security-group --group-id $PUBLIC_SG_ID
fi
######################## Delete Subnets ########################
if grep -q "PUBLIC_SUBNET_ID" "$TEMP_VARS"; then
    echo "Deleting Public Subnet: $PUBLIC_SUBNET_ID ..."
    aws ec2 delete-subnet --subnet-id $PUBLIC_SUBNET_ID
    echo "Deleting Public Route Table: $PUBLIC_ROUTE_TABLE_ID ..."
    aws ec2 delete-route-table --route-table-id $PUBLIC_ROUTE_TABLE_ID
fi
if grep -q "PRIVATE_SUBNET_ID" "$TEMP_VARS"; then
    echo "Deleting Private Subnet: $PRIVATE_SUBNET_ID ..."
    aws ec2 delete-subnet --subnet-id $PRIVATE_SUBNET_ID
    echo "Deleting Private Route Table: $PRIVATE_ROUTE_TABLE_ID ..."
    aws ec2 delete-route-table --route-table-id $PRIVATE_ROUTE_TABLE_ID
fi
######################## Delete VPC peering connection ########################
if grep -q "VPC_PEER_CON_ID" "$TEMP_VARS"; then
    echo "Deleting VPC peering connection: $VPC_PEER_CON_ID ..."
    aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $VPC_PEER_CON_ID
fi
######################## Delete Internet Gateway ########################
if grep -q "IGW_ID" "$TEMP_VARS"; then
    echo "Detaching Internet Gateway: $IGW_ID , from VPC: $NEW_VPC_ID ..."
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $NEW_VPC_ID
    echo "Deleting Internet Gateway: $IGW_ID ..."
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
fi
######################## Delete VPC endpoint ########################
if grep -q "VPC_ENDPOINT_ID" "$TEMP_VARS"; then
        echo "Deleting VPC endpoint: $VPC_ENDPOINT_ID ..."
    aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $VPC_ENDPOINT_ID
fi
######################## Delete new VPC ########################
if grep -q "NEW_VPC_ID" "$TEMP_VARS"; then
    echo "Deleting new VPC: $NEW_VPC_ID ..."
    aws ec2 delete-vpc --vpc-id $NEW_VPC_ID
fi
######################## Delete S3 bucket ########################
# (including all objects)
if grep -q "S3_BUCKET_NAME" "$TEMP_VARS"; then
    echo "Deleting S3 Bucket: $S3_BUCKET_NAME ..."
    aws s3 rm s3://$S3_BUCKET_NAME --recursive
    aws s3api delete-bucket --bucket $S3_BUCKET_NAME --region $REGION
fi
######################## Clear Temporary Variables File ########################
# ATTENTION: all data (IDs) will be lost. #
echo "Clearing Temporary Variables File..."
> $TEMP_VARS
