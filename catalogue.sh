#! /bin/bash

source ./common.sh
app_name=catalogue
check_root

app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Mongosh install"

INDEX=$(mongosh --host $MONGODB_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")

if [ $INDEX -lt 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    
else
    echo -e "$app_name products already exists. $Y..Skipping DB load..$N"

fi

app_restart 
print_total_time