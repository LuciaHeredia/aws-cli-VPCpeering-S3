#!/bin/bash
source config/config.conf # Private Variables file

# set execute permission to files
chmod 400 config/$EC2_KEY_PAIR_NAME.pem 
chmod +x scripts/main.sh
chmod +x scripts/destroy_all.sh
chmod +x scripts/create_vpc.sh
chmod +x scripts/create_vpc_peering.sh
chmod +x scripts/create_subnets.sh
chmod +x scripts/create_ig.sh
chmod +x scripts/create_sg.sh
chmod +x scripts/create_ec2.sh
chmod +x scripts/create_s3.sh
chmod +x scripts/create_vpc_endpoint.sh
