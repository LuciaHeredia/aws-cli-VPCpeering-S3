#!/bin/bash
source config/config.conf # Private Variables file
source "$TEMP_VARS" # Temporary Variables file (IDs)

echo "Creating VPC endpoint for S3 in the private subnet.."
VPC_ENDPOINT_ID=$(aws ec2 create-vpc-endpoint \
    --vpc-id $NEW_VPC_ID \
    --service-name com.amazonaws.$REGION.s3 \
    --vpc-endpoint-type Gateway \
    --route-table-ids $PRIVATE_ROUTE_TABLE_ID \
    --query 'VpcEndpoint.VpcEndpointId' --output text)

# Check if the VPC endpoint was created successfully
if [[ -z "$VPC_ENDPOINT_ID" ]]; then
    echo "--> ERROR creating VPC Endpoint. Process stopped!" >&2
    exit 1
fi
echo "VPC_ENDPOINT_ID=$VPC_ENDPOINT_ID" >> $TEMP_VARS
echo "--> VPC Endpoint Created: $VPC_ENDPOINT_ID"

# Verify if the route for S3 traffic was created
if aws ec2 describe-route-tables \
    --route-table-id $PRIVATE_ROUTE_TABLE_ID \
    --query "RouteTables[*].Routes[?GatewayId=='$VPC_ENDPOINT_ID']" --output text \
    | grep -q "$VPC_ENDPOINT_ID"; then
    echo "--> Route for S3 traffic through VPC Endpoint $VPC_ENDPOINT_ID exists."
else
    echo "--> Error: Route for S3 traffic not found in route table." >&2
    exit 1
fi