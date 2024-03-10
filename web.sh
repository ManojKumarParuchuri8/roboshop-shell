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

dnf install nginx -y &>> $LOGFILE 
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx  &>> $LOGFILE 
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE 
VALIDATE $? "Removing Default Content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE 
VALIDATE $? "Downloading Web Application"

cd /usr/share/nginx/html
VALIDATE $? "Moving to Nginx HTML directory"

unzip -o /tmp/web.zip  &>> $LOGFILE 
VALIDATE $? "Unzipping Web Directory"

cp /home/centos/roboshop-shell/roboshop.conf  /etc/nginx/default.d/roboshop.conf &>> $LOGFILE 
VALIDATE $? "Copying Roboshop reverse proxy Configuration"

systemctl restart nginx  &>> $LOGFILE
VALIDATE $? "Restarting Nginx"