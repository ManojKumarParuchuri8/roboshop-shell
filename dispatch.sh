#!/bin/bash 

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.manojbhavani8.cloud
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

dnf install golang -y
VALIDATE $? "Installing GoLand"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "Roboshop User Creation"
else 
    echo -e "User is already there $Y Skipping.. $N"

mkdir -p /app 

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip
VALIDATE $? "Downloading Dispatch Application"


cd /app 

unzip -o /tmp/dispatch.zip
VALIDATE $? "Unzipping Dispatch Application"

go mod init dispatch

go get 

go build

cp /home/centos/roboshop-shell/dispatch.service  /etc/systemd/system/dispatch.service
VALIDATE $? "Copying Dispatch Service File"

systemctl daemon-reload
VALIDATE $? "Daemon Reload"

systemctl enable dispatch 
VALIDATE $? "enabling dispatch"

systemctl start dispatch
VALIDATE $? "Starting Dipsatch"