#!/bin/bash
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 3600"`
INSTANCE_ID=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id`
TAILSCALE_AUTHKEY=`aws ssm get-parameter --name ${TF_TAILSCALE_AUTHKEY} --region ${TF_AWS_REGION} --with-decryption | jq -r .Parameter.Value`
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --no-source-dest-check
# Install Tailscale
yum install yum-utils -y
yum-config-manager -y --add-repo https://pkgs.tailscale.com/stable/amazon-linux/2023/tailscale.repo
yum install tailscale -y
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sysctl -p /etc/sysctl.d/99-tailscale.conf
systemctl enable --now tailscaled
# TODO: dont hardcode the authkey
tailscale up --advertise-routes=10.0.0.0/19,10.0.32.0/19 --accept-routes --advertise-tags=tag:aws --authkey=$TAILSCALE_AUTHKEY
