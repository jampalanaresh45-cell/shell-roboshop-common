#!/bin/bash

source ./common.sh
app_name=redis
check_root

dnf module disable $app_name -y &>>$LOG_FILE
VALIDATE $? "Redis module disabling"

dnf module enable $app_name:7 -y &>>$LOG_FILE
VALIDATE $? "Redis module enabling"

dnf install $app_name -y &>>$LOG_FILE
VALIDATE $? "Redis installation"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/$app_name/$app_name.conf &>>$LOG_FILE
VALIDATE $? "Allowing remote connections in $app_name"

systemctl enable $app_name &>>$LOG_FILE
VALIDATE $? "Enable $app_name service"

systemctl start $app_name &>>$LOG_FILE
VALIDATE $? "Start $app_name service"

print_total_time