#!/bin/bash 

LOG_FILE="tmp/roboshop-log-files"
AMI=ami-0f3c7d07486cad139
SG_ID=sg-09eedeaafa1a78313
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
HOSTED_ZONE=Z07941241NXKHP2F6HD44
DOMAIN_NAME="manojbhavani8.cloud"

for i in "${INSTANCES[@]}"
do 
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then 
        INSTANCE_TYPE="t3.small"
    else 
        INSTANCE_TYPE="t2.micro"
    fi 

    Ip_Address=$(aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCE_TYPE --security-group-ids sg-09eedeaafa1a78313 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"  --query 'Instances[0].PrivateIpAddress' --output text)  #we are creating for instances 
    echo "$i : $Ip_Address"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$Ip_Address'"
            }]
        }
        }]
    }'
    done 


