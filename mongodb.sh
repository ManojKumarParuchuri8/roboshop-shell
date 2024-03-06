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
        echo "$2 is Failed"
    else 
        echo "$2 is SUCCESS"
    fi 
}

echo -e "$R Manoj $N  $Y Kumar $N"