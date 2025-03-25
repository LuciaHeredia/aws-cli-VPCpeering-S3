#!/bin/bash
source config/config.conf # Private Variables file

# Variables
RANDOM_STR=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 10)
S3_BUCKET_NAME="s3-$RANDOM_STR"

###################################################

echo "Creating S3 bucket..."
aws s3api create-bucket \
    --bucket $S3_BUCKET_NAME --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION

# Check if the bucket was created successfully
if aws s3api head-bucket --bucket $S3_BUCKET_NAME 2>/dev/null; then
    echo "S3_BUCKET_NAME=$S3_BUCKET_NAME" >> $TEMP_VARS
    echo "--> S3 Bucket $S3_BUCKET_NAME created successfully."
else
    echo "--> Error: S3 Bucket $S3_BUCKET_NAME was not created." >&2
    exit 1
fi
