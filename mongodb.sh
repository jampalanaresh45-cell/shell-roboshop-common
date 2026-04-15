#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
    VALIDATE $? "Adding Mongodb repo"

    dnf install mongodb-org -y &>>$LOG_FILE    
    VALIDATE $? "mongodb installation"

    systemctl enable mongod &>>$LOG_FILE
    VALIDATE $? "Enabling Mongodb"

    systemctl start mongod &>>$LOG_FILE
    VALIDATE $? "Starting Mongodb"

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
    VALIDATE $? "Allowing remote connections in Mongodb"

    systemctl restart mongod &>>$LOG_FILE
    VALIDATE $? "Restarting Mongodb"

    print_total_time