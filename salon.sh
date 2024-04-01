#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -c"
echo -e "~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
if [[ ! -z $1 ]]
then
  echo -e "\n$1"
fi 
echo "$($PSQL"select * from services order by service_id;")" | while read SERVICE_ID BAR SERVICE_NAME
do
if [[  $SERVICE_ID =~ ^[0-9]+$ ]]
then
echo -e "$SERVICE_ID) $SERVICE_NAME"
fi
done
read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then 
  MAIN_MENU "Please insert a number !!"
else
  SERVICE_ID_COMMAND=$($PSQL "select service_id from services where service_id='$SERVICE_ID_SELECTED'")
  if [[ $SERVICE_ID_SELECTED == *"0 rows"* ]]
  then
  MAIN_MENU "I could not find that service. What would you like today?"
  else
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME_COMMAND=$(echo "$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")" | sed -r '1,2d; s/ //g; s/[^a-zA-Z]|row+//g')
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  if [[ $CUSTOMER_NAME == *"0 rows"* ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERTED_CUSTOMER_NAME=$($PSQL"insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi
  SERVICE_NAME_SELECTED=$(echo "$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")" | sed -r '1,2d; s/ //g; s/[^a-zA-Z]|row+//g')
  echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  CUSTOMER_ID_OUTPUT=$(echo "$CUSTOMER_ID" | grep -o '[0-9]\+' | head -1)
  INSERT_APPOINTMENTS=$($PSQL "insert into appointments(customer_id,time,service_id) values($CUSTOMER_ID_OUTPUT,'$SERVICE_TIME',$SERVICE_ID_SELECTED)")
  echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
fi
}

MAIN_MENU