#!/bin/bash
dnf update -y
dnf install -y ec2-instance-connect
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
dnf install -y gcc git make
git clone https://github.com/WireGuard/wireguard-tools.git /tmp/wireguard-tools
make -C /tmp/wireguard-tools/src install
# TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
# MAC=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/mac)
# ENI=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/interface-id/")
# EIPALLOC=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/eipalloc)
# aws ec2 associate-address --network-interface-id "$ENI" --allocation-id "$EIPALLOC" --allow-reassociation