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

<< COMMENT
# Retrieve PrefixListId of the Amazon S3 managed prefix list in the region
PREFIX_LIST_ID=$(aws ec2 describe-managed-prefix-lists \
        --query "PrefixLists[?PrefixListName=='com.amazonaws.$REGION.s3'].PrefixListId" --output text)

# Update the route table of Private Subnet to route S3 traffic through the VPC endpoint
aws ec2 create-route \
    --route-table-id $PRIVATE_ROUTE_TABLE_ID \
    --destination-prefix-list-id $PREFIX_LIST_ID \
    --vpc-endpoint-id $VPC_ENDPOINT_ID
echo "--> Private Subnet Route Table Updated for S3 Traffic"
COMMENT

