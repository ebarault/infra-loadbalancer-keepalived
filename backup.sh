#!/bin/bash

NOW=$(date +"%D %T")

echo "$NOW - info: $1 is BACKUP" >> /var/log/keepalived.log

# private ip address for loadbalancing private frontend (lb.private.carbicloud1.com), assigned to current host when turning MASTER
LB_PRI_IP=172.31.71.1
LB_PRI_IP_MASK=/20

# util function to turn RESULT in OK if empty
function evalRESULT() {
        if [ -z "${RESULT}" ]; then
                RESULT=OK
        fi
}

# manually remove the ec2 assigned private ip from host network config
echo "$NOW - exec: sudo ip addr del $LB_PRI_IP$LB_PRI_IP_MASK dev eth0" >> /var/log/keepalived.log
RESULT=$(sudo ip addr del $LB_PRI_IP$LB_PRI_IP_MASK dev eth0 2>&1)

evalRESULT RESULT
echo "$NOW - info: $RESULT" >> /var/log/keepalived.log
