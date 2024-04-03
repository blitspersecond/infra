#!/bin/bash
echo ECS_CLUSTER=${environment} >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVER=["json-file","awslogs","none"] >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config
echo ECS_AWSVPC_BLOCK_IMDS=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_CPU_MEM_LIMIT=true >> /etc/ecs/ecs.config
yum update -y
yum install -y iptables-services
sysctl -w net.ipv4.conf.all.route_localnet=1
iptables --insert DOCKER-USER 1 --in-interface docker+ --destination 169.254.169.254/32 --jump DROP
iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
iptables-save | tee /etc/sysconfig/iptables && sudo systemctl enable --now iptables
yum install -y ec2-instance-connect

