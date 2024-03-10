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

dnf module disable mysql -y &>> $LOGFILE 
VALIDATION $? "Disabling MySQL"

cp /home/centos/roboshop-shell/mysql.repo  /etc/yum.repos.d/mysql.repo &>> $LOGFILE 
VALIDATION $? "Copying MySQL repo"

dnf install mysql-community-server -y &>> $LOGFILE 
VALIDATION $? "Installing MySQL community server"

systemctl enable mysqld &>> $LOGFILE 
VALIDATION $? "Enabling Mysql"

systemctl start mysqld &>> $LOGFILE 
VALIDATION $? "Starting Mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE 
VALIDATION $? "Setting Mysql Root Password"

mysql -uroot -pRoboShop@1
