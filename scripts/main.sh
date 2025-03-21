#!/bin/bash
source config/config.conf # Private Variables file

touch "$TEMP_VARS" # create Temporary Variables file

######################## 1. New VPC ########################
if ! grep -q "NEW_VPC_ID" "$TEMP_VARS"; then
    ./scripts/create_vpc.sh
fi
######################## 2. Internet Gateway ########################
if ! grep -q "IGW_ID" "$TEMP_VARS"; then
    ./scripts/create_ig.sh
fi
######################## 3. Subnets ########################
./scripts/create_subnets.sh
######################## 4. VPC Peering ########################
if ! grep -q "VPC_PEER_CON_ID" "$TEMP_VARS"; then
    ./scripts/create_vpc_peering.sh
fi
######################## 5. EC2 Instances ########################
# TODO: echo "Creating EC2 Instances..."
##
##


#######
echo "--> Deployment complete!"