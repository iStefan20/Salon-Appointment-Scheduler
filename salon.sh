#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~n"
echo -e "Welcome to My Salon, how can I help you?\n"

# MAIN MENU
while true;
do
  # list of services
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  # prints list 
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
   echo "$SERVICE_ID) $SERVICE_NAME"
  done
  

  read SERVICE_ID_SELECTED
  # retrive available services 
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  # if not found
  if [[ -z $SERVICE_NAME ]]
   then
     # error message
     echo -e "\nI could not find that service. What would you like today?"
   else 
     # if user input within the range stop the condition
     break
   fi
done

# phone number 
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# find customer_id for provide phone number
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

#if not found
if [[ -z $CUSTOMER_ID ]]
then 

   # error message
   echo -e "\nI don't have a record for that phone number, what's your name?"
   # collect customer name if provided phone number not in database
   read CUSTOMER_NAME
   
   # insert name phone into customers table
   INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
   # get customer_id
   CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
else
   # get customer_name
   CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
fi

# print error message
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"

# ask service_timeings
read SERVICE_TIME

# insert data into appointments table
INSERT_APPOINTMENTS_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

# print exit message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
