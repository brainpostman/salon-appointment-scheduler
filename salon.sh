#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Hair Salon ~~~~"

echo -e "\nWelcome to my salon, how can I help you?"

MAIN_MENU() {
  if [[ $1 ]]
    then 
      echo -e "\n$1"
  fi
  COUNT=$($PSQL "select count(*) from services")
  i=1
  while [[ $i -le $COUNT ]]
    do
      SERVICE=$($PSQL "select name from services where service_id=$i")
      echo "$i)$SERVICE"
      i=$(( i+1 ))
    done
  CUSTOMER_INFO    
}

CUSTOMER_INFO() {
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED'")  
  if [[ -z $SERVICE_NAME ]]
    then 
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
        then 
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          CUSTOMER_INSERT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
          CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
        else
          CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
      fi
      echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CREATE_APPOINTMENT $SERVICE_ID_SELECTED "$SERVICE_NAME" "$SERVICE_TIME" "$CUSTOMER_PHONE" "$CUSTOMER_NAME"
  fi
}
  
  CREATE_APPOINTMENT() {
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT=$($PSQL "insert into appointments(service_id, customer_id, time) values($1, $CUSTOMER_ID,'$2')")
  if [[ -z $INSERT_APPOINTMENT ]]
  then
  echo -e "\nInsert not successful."
  else
    echo -e "\nI have put you down for a$2 at $3, $5."
  fi
}

MAIN_MENU
