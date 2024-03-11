#!/bin/bash
yum update -y
yum install -y iptables-services unzip ec2-instance-connect wget awscli-2
wget https://github.com/AndrewGuenther/fck-nat/releases/download/v1.3.0/fck-nat-1.3.0-any.rpm -O /tmp/fck-nat-1.3.0-any.rpm
rpm -i /tmp/fck-nat-1.3.0-any.rpm 
systemctl enable fck-nat.service