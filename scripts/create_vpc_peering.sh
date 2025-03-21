#!/bin/bash
source config/config.conf # Private Variables file
source "$TEMP_VARS" # Temporary Variables file

echo "Creating VPC peering connection..."
VPC_PEER_CON_ID=$(aws ec2 create-vpc-peering-connection \
        --vpc-id $NEW_VPC_ID --peer-vpc-id $DEFAULT_VPC_ID \
        --region $REGION \
        --query 'VpcPeeringConnection.VpcPeeringConnectionId ' --output text)

if [ -z "$VPC_PEER_CON_ID" ]; then
    echo "--> ERROR creating VPC peering connection. Process stopped!"
    exit 1
fi

echo "VPC_PEER_CON_ID=$VPC_PEER_CON_ID" >> $TEMP_VARS
echo "--> Created peering connection: $VPC_PEER_CON_ID"
#######
echo "Accepting connection request..."
aws ec2 accept-vpc-peering-connection \
        --vpc-peering-connection-id $VPC_PEER_CON_ID
#######
echo "Waiting for VPC Peering Connection to become active..."
COUNTER_SLEEP=5
# MAX waiting: 5rounds * 5seconds = 25seconds
while true; do
    PEER_STATUS=$(aws ec2 describe-vpc-peering-connections \
        --vpc-peering-connection-ids $VPC_PEER_CON_ID \
        --region $REGION \
        --query 'VpcPeeringConnections[0].Status.Code' --output text)
    
    if [ "$PEER_STATUS" == "active" ]; then
        echo "--> VPC Peering Connection is now ACTIVE."
        break
    fi
    
    if [ $COUNTER_SLEEP -eq 0 ]; then
        echo "--> ERROR establishing VPC peering connection. Process stopped!"
        aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $VPC_PEER_CON_ID
        sed -i "/^VPC_PEER_CON_ID/d" $TEMP_VARS
        exit 1
    fi

    echo "Current status: $PEER_STATUS. Retrying in 5 seconds..."
    sleep 5
    ((COUNTER_SLEEP-=1))
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
        --vpc-peering-connection-id $VPC_PEER_CON_ID \
        --region $REGION
echo "--> Added route to New VPC Route Table: $NEW_VPC_ROUTE_TABLE_ID"
aws ec2 create-route \
        --route-table-id $DEFAULT_VPC_ROUTE_TABLE_ID \
        --destination-cidr-block $NEW_VPC_CIDR_BLOCK \
        --vpc-peering-connection-id $VPC_PEER_CON_ID \
        --region $REGION
echo "--> Added route to Default VPC Route Table: $DEFAULT_VPC_ROUTE_TABLE_ID"
#######
echo "--> VPC Peering setup complete!"
