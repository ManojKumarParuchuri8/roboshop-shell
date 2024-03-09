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
VALIDATE $? "Disabling MongoDB"

dnf module enable nodejs:18 -y &>> $LOGFILE 
VALIDATE $? "Enabling MongoDB"


dnf install nodejs -y &>> $LOGFILE 
VALIDATE $? "Installing MongoDB"

id roboshop 
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "Roboshop User Creation"
else 
    echo -e "User is there we are $Y Skipping $N"
fi 

mkdir -p /app &>> $LOGFILE 
VALIDATE $? "Creating App Directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE 
VALIDATE $? "Downloading the User Application"

cd /app 

unzip /tmp/user.zip &>> $LOGFILE 
VALIDATE $? "Unzipping the User Directory"


npm install  &>> $LOGFILE 
VALIDATE $? "Installing the dependencies"


cp /home/centos/roboshop-shell/user.service  /etc/systemd/system/user.service &>> $LOGFILE 
VALIDATE $? "Copying User Service file"


systemctl daemon-reload &>> $LOGFILE 
VALIDATE $? "User Daemon Reload"

systemctl enable user  &>> $LOGFILE 
VALIDATE $? "Enabling User"


systemctl start user &>> $LOGFILE 
VALIDATE $? "Starting the user"


cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE 
VALIDATE $? "Copying the MongoDB Repo"


dnf install mongodb-org-shell -y &>> $LOGFILE 
VALIDATE $? "Installing the MongoDB Client"


mongo --host mongodb.manojbhavani8.cloud </app/schema/user.js &>> $LOGFILE 
VALIDATE $? "Connecting to MongoDB Server"

