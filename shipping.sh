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

dnf install maven -y &>> $LOGFILE 
VALIDATE $? "Installing Maven"

id roboshop 
if [ $? -ne 0 ]
then 
    useradd roboshop
    echo $? "Roboshop user creation"
else 
    echo -e "User is already there $Y Skipping... $N" 


mkdir -p /app

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE 
VALIDATE $? "Downloading Shipping Application"

cd /app

unzip -o /tmp/shipping.zip &>> $LOGFILE 
VALIDATE $? "Unzipping Shipping Repository"

mvn clean package &>> $LOGFILE 
VALIDATE $? "Downloading Dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE 
VALIDATE $? "Renaming from shipping-1.0 to shipping"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE 
VALIDATE $? "copying Shipping Service"

systemctl daemon-reload &>> $LOGFILE 

systemctl enable shipping  &>> $LOGFILE 
VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE 
VALIDATE $? "Starting Shipping"

dnf install mysql -y &>> $LOGFILE 
VALIDATE $? "Installing MySQL"

mysql -h mysql.manojbhavani8.cloud -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE 

systemctl restart shipping &>> $LOGFILE 
VALIDATE $? "Restarting shipping"