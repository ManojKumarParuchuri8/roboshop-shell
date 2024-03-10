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

dnf install python36 gcc python3-devel -y &>> $LOGFILE 
VALIDATE $? "Installing Python"

id roboshop 
if [ $? -ne 0 ]
then 
    useradd roboshop 
    VALIDATION $? "Roboshop user creation"
else 
    echo -e "User is already there $Y Skipping.. $N"
fi 


mkdir -p /app

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading Payment Application"

cd /app 

unzip -o /tmp/payment.zip  &>> $LOGFILE
VALIDATE $? "Unzipping Payment Directory"

pip3.6 install -r requirements.txt  &>> $LOGFILE
VALIDATE $? "Downloading Requirements"

cp /home/centos/roboshop-shell/payment.service  /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "Copying Payment Service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon Reload"

systemctl enable payment  &>> $LOGFILE
VALIDATE $? "Enabling Payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting payment"