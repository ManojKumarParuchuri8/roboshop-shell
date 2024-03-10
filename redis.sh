#!/bin/bash 

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE 

VALIDATE()
{
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is Failed"
        exit 1 
    else 
        echo -e "$2 is SUCCESS"
    fi 
}

if [ $ID -ne 0 ] 
 then 
    echo -e " ERROR:: Please run this script with root access"
    exit 1 #you can give other than 0
else 
    echo "you are root user"
fi 

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE 
VALIDATE $? "Installing Remi Release"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "Enabling Remi Module"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Installing Redis"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf  &>> $LOGFILE
VALIDATE $? "Replacing the IP Address"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "Enabling Redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "Starting Redis"