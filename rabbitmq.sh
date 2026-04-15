#!/bin/bash
source ./common.sh
check_root
app_name="rabbitmq"

cp $SCRIPT_DIR/$app_name.repo /etc/yum.repos.d/$app_name.repo &>>$LOG_FILE
VALIDATE $? "Adding $app_name repo"
dnf install $app_name-server -y &>>$LOG_FILE
VALIDATE $? "Rabbitmq installation"
systemctl enable $app_name-server &>>$LOG_FILE
VALIDATE $? "Enable $app_name service"
systemctl start $app_name-server &>>$LOG_FILE
VALIDATE $? "Start $app_name service"    

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
VALIDATE $? "Creating application user in $app_name"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Creating application user and setting permission in $app_name"

print_total_time