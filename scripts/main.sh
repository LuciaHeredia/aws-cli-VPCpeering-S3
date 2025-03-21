#!/bin/bash
source config/config.conf # Private Variables file

touch "$TEMP_VARS" # create Temporary Variables file

######################## 1. New VPC ########################
./scripts/create-vpc.sh
if ! grep -q "NEW_VPC_ID" "$TEMP_VARS"; then
    echo "ERROR creating VPC. Process stopped!"
    break;
fi

<< 'COMMENT'

######################## 2. VPC Peering ########################
echo "Creating VPC peering connection..."
VPC_PEER_CON_ID=$(aws ec2 create-vpc-peering-connection \
        --vpc-id $VPC_ID --peer-vpc-id $VPC_ID_DEFAULT \
        --region $REGION \
        --query 'VpcPeeringConnection.VpcPeeringConnectionId ' --output text)
echo "VPC_PEER_CON_ID=$VPC_PEER_CON_ID" >> $TEMP_VARS
echo "--> Created peering connection: $VPC_PEER_CON_ID"
#######
echo "Accepting connection request..."
aws ec2 accept-vpc-peering-connection \
        --vpc-peering-connection-id $VPC_PEER_CON_ID
#######
echo "Waiting for VPC Peering Connection to become active..."
while true; do
    PEER_STATUS=$(aws ec2 describe-vpc-peering-connections \
        --vpc-peering-connection-ids $VPC_PEER_CON_ID \
        --region $REGION \
        --query 'VpcPeeringConnections[0].Status.Code' --output text)
    
    if [ "$PEER_STATUS" == "active" ]; then
        echo "--> VPC Peering Connection is now ACTIVE."
        break
    fi
    
    echo "Current status: $PEER_STATUS. Retrying in 5 seconds..."
    sleep 5
done
#######
# Get the route tables for both VPCs
NEW_VPC_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
        --filters Name=vpc-id,Values=$NEW_VPC_ID \
        --region $REGION \
        --query 'RouteTables[0].RouteTableId' --output text)
DEFAULT_VPC_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
        --filters Name=vpc-id,Values=$DEFAULT_VPC_ID \
        --region $REGION \
        --query 'RouteTables[0].RouteTableId' --output text)
#######
echo "Adding routes for communication between VPCs..."
aws ec2 create-route \
        --route-table-id $NEW_VPC_ROUTE_TABLE_ID \
        --destination-cidr-block $DEFAULT_VPC_CIDR_BLOCK \
        --vpc-peering-connection-id $PEERING_CONNECTION_ID \
        --region $REGION
echo "--> Added route to New VPC Route Table: $NEW_VPC_ROUTE_TABLE_ID"
aws ec2 create-route \
        --route-table-id $DEFAULT_VPC_ROUTE_TABLE_ID \
        --destination-cidr-block $NEW_VPC_CIDR_BLOCK \
        --vpc-peering-connection-id $PEERING_CONNECTION_ID \
        --region $REGION
echo "--> Added route to Default VPC Route Table: $DEFAULT_VPC_ROUTE_TABLE_ID"
#######
echo "--> VPC Peering setup complete!"
######################## 3. EC2 Instances ########################
# TODO: echo "Creating Public and Private Subnets..."
##
##


# TODO: echo "Creating EC2 Instances..."
##
##
COMMENT

#######
echo "--> Deployment complete!"