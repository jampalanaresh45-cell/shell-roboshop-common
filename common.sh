#! /bin/bash
####Logging in shell script####
USERID=$(id -u)
R="\e[31m" #Red
G="\e[32m" #Green
Y="\e[33m" #Yellow
N="\e[0m"  #No Color

LOG_FOLDER="/var/log/shellroboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)
SCRIPT_DIR=$pwd
MONGODB_HOST=mongo.daws86s.store

mkdir -p $LOG_FOLDER
echo "script started at $(date)" | tee -a $LOG_FILE

check_root(){
if [ $USERID -ne 0 ]; then
    echo "ERROR:: User must have privilege access" | tee -a $LOG_FILE
    exit 1
fi
}

VALIDATE(){
        if [ $1 -ne 0 ]; then
        echo -e "$2 is failed $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 succeeded $N" | tee -a $LOG_FILE
    fi
}
nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Nodejs module disable"
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Nodejs20 module enabled"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Nodejs install"
    
    npm install &>>$LOG_FILE
    VALIDATE $? "npm dependencies installation"
}
java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "maven installation"

    mvn clean package &>>$LOG_FILE
    VALIDATE $? "maven build"

    mv target/$app_name-1.0.jar $app_name.jar &>>$LOG_FILE
    VALIDATE $? "Renaming $app_name jar file"
}
app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        echo "Adding roboshop user"
        VALIDATE $? "Adding roboshop user"
    else
        echo -e "roboshop user already exists. $Y..Skipping user creation..$N"
    fi
    mkdir /app 
    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip 
    cd /app 
    VALIDATE $? "Changing to app directory"
    rm -rf /app/* &>>$LOG_FILE
    VALIDATE $? "Cleaning up existing code"

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Catalogue unzip $app_name"
    
}
systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copying $app_name systemd file"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "Reloading systemd"

    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enabling $app_name"

}
app_restart(){
    systemctl restart $app_name &>>$LOG_FILE
    VALIDATE $? "Restarting $app_name"
}
print_total_time(){
    END_TIME=$(date +%s)
    ELAPSED_TIME=$(($END_TIME - $START_TIME))
    echo -e "Scipt executed in :$Y $ELAPSED_TIME seconds $N"
}
