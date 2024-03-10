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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE 

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE 

dnf install rabbitmq-server -y  &>> $LOGFILE 
VALIDATE $? "Installing Rabbitmq server"

systemctl enable rabbitmq-server  &>> $LOGFILE 
VALIDATE $? "Enabling Rabbitmq server"

systemctl start rabbitmq-server  &>> $LOGFILE 
VALIDATE $? "Starting Rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE 
VALIDATE $? "Adding User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE 
VALIDATE $? "Setting Permissions"