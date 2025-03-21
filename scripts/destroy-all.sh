#!/bin/bash
source config/config.conf # private variables file
source "$TEMP_VARS" # temporary variables file

######################## Delete VPC peering connection ########################
if grep -q "VPC_PEER_CON_ID" "$TEMP_VARS"; then
    echo "Deleting VPC peering connection..."
    aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $VPC_PEER_CON_ID
fi
######################## Delete new VPC ########################
if grep -q "NEW_VPC_ID" "$TEMP_VARS"; then
    echo "Deleting new VPC..."
    aws ec2 delete-vpc --vpc-id $NEW_VPC_ID
fi
######################## Clear Temporary Variables File ########################
echo "Clearing Temporary Variables File..."
> $TEMP_VARS