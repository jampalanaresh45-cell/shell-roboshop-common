#!/bin/bash
source ./common.sh
check_root
app_name="mysql"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "MySQL installation"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySQL"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting MySQL"    

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "Setting MySQL root password"

print_total_time 