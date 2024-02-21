#!/bin/bash
dnf update -y
dnf install -y ec2-instance-connect
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
dnf install -y gcc git make
git clone https://github.com/WireGuard/wireguard-tools.git /tmp/wireguard-tools
make -C /tmp/wireguard-tools/src install
