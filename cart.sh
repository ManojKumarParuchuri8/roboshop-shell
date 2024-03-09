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

dnf module disable nodejs -y &>> $LOGFILE 
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling NodeJS"

dnf install nodejs -y &>> $LOGFILE 
VALIDATE $? "Installing NodeJS"

id roboshop
if[ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "Roboshop User Creation"
else 
    echo -e "Roboshop user is already there $Y Skipping $N "
fi 


mkdir -p /app  &>> $LOGFILE 
VALIDATE $? "Creating App Directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE 
VALIDATE $? "Downloading Cart Application" 

cd /app 

unzip /tmp/cart.zip &>> $LOGFILE 
VALIDATE $? "Unzipping Cart"

npm install  &>> $LOGFILE 
VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop-shell/cart.service  /etc/systemd/system/cart.service &>> $LOGFILE 
VALIDATE $? "Copying Cart.service File"

systemctl daemon-reload  &>> $LOGFILE 
VALIDATE $? "Cart daemon reload"

systemctl enable cart  &>> $LOGFILE 
VALIDATE $? "enabling Cart"

systemctl start cart  &>> $LOGFILE 
VALIDATE $? "Starting cart"
