#!/bin/bash
source config.conf # private variables file
source "$TEMP_VARS" # temporary variables file

######################## Delete VPC peering connection ########################
echo "Deleting VPC peering connection..."
aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $VPC_PEER_CON_ID

######################## Delete new VPC ########################
echo "Deleting new VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID

######################## Clear Temporary Variables File ########################
echo "Clearing Temporary Variables File..."
> temp.conf