#!/bin/bash
source config/config.conf # Private Variables file

touch "$TEMP_VARS" # create Temporary Variables file (IDs)

<< 'COMMENT'
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
######################## 5. Security Groups ########################
./scripts/create_sg.sh
######################## 6. EC2 Instances ########################
./scripts/create_ec2.sh
COMMENT

######################## 7. S3 Bucket ########################
if ! grep -q "S3_BUCKET_NAME" "$TEMP_VARS"; then
    ./scripts/create_s3.sh
fi
######################## 8. VPC Endpoint ########################

######################## 9. Upload to S3 ########################


#######
echo "--> Deployment complete!"