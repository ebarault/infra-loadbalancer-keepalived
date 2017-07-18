#!/bin/bash

NOW=$(date +"%D %T")

echo "$NOW - info: $1 is MASTER" >> /var/log/keepalived.log

# interface id for which we want to associate the elastic ip: current host interface
ENI_LB01=eni-4c7cb821
ENI_LB02=eni-8861a5e5

# 
RT_PRI=rtb-bdea0fd5
RT_AS=rtb-62c9090a
RT_BO=rtb-0b8b4062


# Elastic IP allocation Id for the IP we want to associate
EIP_CARBIPCLOUD=eipalloc-97bf32fe

# private ip address for loadbalancing private frontend (lb.private.carbicloud1.com), assigned to current host when turning MASTER
LB_PRI_IP=172.31.71.1
LB_PRI_IP_MASK=/20


# util function to turn RESULT in OK if empty
function evalRESULT() {
	if [ -z "${RESULT}" ]; then
        	RESULT=OK
	fi
}

# associate carbipcloud elastic ip with LB01 network interface
echo "$NOW - exec: aws ec2 associate-address --network-interface-id $ENI_LB01 --allocation-id $EIP_CARBIPCLOUD --allow-reassociation" >> /var/log/keepalived.log
RESULT=$(aws ec2 associate-address --network-interface-id $ENI_LB01 --allocation-id $EIP_CARBIPCLOUD --allow-reassociation --output text 2>&1)

evalRESULT RESULT
echo "$NOW - info: $RESULT" >> /var/log/keepalived.log

# set LB01 as any host route for zone AS 
echo "$NOW - exec: aws ec2 replace-route --route-table-id $RT_AS --destination-cidr-block 0.0.0.0/0 --network-interface-id $ENI_LB01" >> /var/log/keepalived.log
RESULT=$(aws ec2 replace-route --route-table-id $RT_AS --destination-cidr-block 0.0.0.0/0 --network-interface-id $ENI_LB01 2>&1)

evalRESULT RESULT
echo "$NOW - info: $RESULT" >> /var/log/keepalived.log

# set LB01 as any host route for zone PRI 
echo "$NOW - exec: aws ec2 replace-route --route-table-id $RT_PRI --destination-cidr-block 0.0.0.0/0 --network-interface-id $ENI_LB01" >> /var/log/keepalived.log
RESULT=$(aws ec2 replace-route --route-table-id $RT_PRI --destination-cidr-block 0.0.0.0/0 --network-interface-id $ENI_LB01 2>&1)

evalRESULT RESULT
echo "$NOW - info: $RESULT" >> /var/log/keepalived.log

# assign loadbalancing frontend ip as host secondary private ip (aws)
echo "$NOW - exec: aws ec2 assign-private-ip-addresses --network-interface-id $ENI_LB01 --private-ip-addresses $LB_PRI_IP --allow-reassignment" >> /var/log/keepalived.log
RESULT=$(aws ec2 assign-private-ip-addresses --network-interface-id $ENI_LB01 --private-ip-addresses $LB_PRI_IP --allow-reassignment 2>&1)

evalRESULT RESULT
echo "$NOW - info: $RESULT" >> /var/log/keepalived.log

# manually add the aws assigned private ip to current host network interface
echo "$NOW - exec: sudo ip addr add $LB_PRI_IP$LB_PRI_IP_MASK dev eth0" >> /var/log/keepalived.log
RESULT=$(sudo ip addr add $LB_PRI_IP$LB_PRI_IP_MASK dev eth0 2>&1)

evalRESULT RESULT
echo "$NOW - info: $RESULT" >> /var/log/keepalived.log

