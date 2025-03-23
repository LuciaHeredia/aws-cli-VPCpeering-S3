#!/bin/bash
source config/config.conf # Private Variables file
source "$TEMP_VARS" # Temporary Variables file (IDs)

echo "Launching Public EC2..."
PUBLIC_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID --region $REGION \
    --instance-type $INSTANCE_TYPE \
    --key-name $EC2_KEY_PAIR_NAME \
    --subnet-id $PUBLIC_SUBNET_ID \
    --security-group-ids $PUBLIC_SG_ID \
    --associate-public-ip-address \
    --query 'Instances[0].InstanceId' --output text)
echo "PUBLIC_INSTANCE_ID=$PUBLIC_INSTANCE_ID" >> $TEMP_VARS
echo "--> Launched Public EC2: $PUBLIC_INSTANCE_ID"

echo "Waiting for the instance to be running..."
aws ec2 wait instance-running --instance-ids $PUBLIC_INSTANCE_ID --region $REGION

# Get Public IP of the Public Instance
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $PUBLIC_INSTANCE_ID --region $REGION \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "--> Public EC2 Instance Public IP: $PUBLIC_IP"
#######
echo "Launching Private EC2..."
PRIVATE_INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID --region $REGION \
    --instance-type $INSTANCE_TYPE \
    --key-name $EC2_KEY_PAIR_NAME \
    --subnet-id $PRIVATE_SUBNET_ID \
    --security-group-ids $PRIVATE_SG_ID \
    --query 'Instances[0].InstanceId' --output text)
echo "PRIVATE_INSTANCE_ID=$PRIVATE_INSTANCE_ID" >> $TEMP_VARS
echo "--> Launched Private EC2: $PRIVATE_INSTANCE_ID"

echo "Waiting for the instance to be running..."
aws ec2 wait instance-running --instance-ids $PRIVATE_INSTANCE_ID --region $REGION

# Get Private IP of the Private Instance
PRIVATE_IP=$(aws ec2 describe-instances \
    --instance-ids $PRIVATE_INSTANCE_ID --region $REGION \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
echo "--> Private EC2 Instance Private IP: $PRIVATE_IP"
#######
echo "Instances successfully launched!"

# Display SSH connection command
echo "To SSH into the Public EC2 Instance, use:"
echo "ssh -i <EC2_KEY_PAIR_NAME>.pem ec2-user@<PUBLIC_IP>"

echo "Once connected to the Public EC2, SSH into the Private EC2 using:"
echo "ssh -i <EC2_KEY_PAIR_NAME>.pem ec2-user@<PRIVATE_IP>"

echo "For Verification:"
echo "Run 'ifconfig' or 'ip' a on the private EC2 instance to verify the internal IP."
echo "Try pinging the private EC2 from the public EC2: $ ping <PRIVATE_IP>"
