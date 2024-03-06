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

dnf module disable nodejs -y &>> $LOGFILE 
VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE 
VALIDATE $? "Enabling NODEJS:18"

dnf install nodejs -y &>> $LOGFILE 
VALIDATE $? "Installing NodeJS"

id roboshop 
if [ $? -ne 0 ]
then 
    useradd roboshop &>> $LOGFILE 
    VALIDATE $? "Roboshop User Creation"
else 
    echo -e "User is there we are $Y skipping $N"
fi 

VALIDATE $? "Creating Roboshop USER" 

mkdir -p /app
VALIDATE $? "Creating the App Directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Downloading the Catalogue Application"

cd /app

unzip -o /tmp/catalogue.zip &>> $LOGFILE 
VALIDATE $? "Unzipping the catalogue"

npm install &>> $LOGFILE 
VALIDATE $? "Installing Dependencies"

#we cloned this roboshop-shell in this absolute path
cp /home/centos/roboshop-shell/catalogue.service  /etc/systemd/system/catalogue.service
VALIDATE $? "copying catalogue serivice file"

systemctl daemon-reload &>> $LOGFILE  
VALIDATE $? "Catalogue daemon-reload"

systemctl enable catalogue &>> $LOGFILE 
VALIDATE $? "Enabling Catalogue"

systemctl start catalogue &>> $LOGFILE  
VALIDATE $? "Starting Catalogue"

cp /home/centos/roboshop-shell/mongo.repo  /etc/yum.repos.d/mongo.repo &>> $LOGFILE 
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org-shell -y &>> $LOGFILE 
VALIDATE $? "Installing MongoDB Client"

mongo --host  $MONGODB_HOST </app/schema/catalogue.js
VALIDATE $? "Loading Catalogue DATA into MongoDB"

