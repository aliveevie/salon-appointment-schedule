#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
echo -e "\n~~~~~ Salon Appoitnments ~~~~~\n"  


while IFS="|" read SERVICE_ID NAME; do
  SERVICE_LIST+="$SERVICE_ID) $NAME"$'\n'
done < <($PSQL "SELECT * FROM services")
SERVICE_ID=$($PSQL "SELECT service_id FROM services")
declare SERVICE_ID_SELECTED

SERVICES_MENU(){
        echo -e "Welcome to my salon how can I help you\n"
        echo "$SERVICE_LIST"
        
        read SERVICE_ID_SELECTED
        
        if [[ $SERVICE_ID =~ $SERVICE_ID_SELECTED ]]
        then
            SERVICES_IN_LIST
        else
            SERVICES_NOT_IN_LIST
        fi
       
}
SERVICES_IN_LIST(){
   echo "What's your phone number?"
   read CUSTOMER_PHONE
   CUSTOMER_IDS=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
   SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
   if [[ -z $CUSTOMER_IDS ]]
   then
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_N=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
    echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) 
                VALUES($CUSTOMER_N, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"
        )
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    
    else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
         CUSTOMER_N=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
         read SERVICE_TIME
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) 
                VALUES($CUSTOMER_N, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"
        )
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    
    fi
}
SERVICES_NOT_IN_LIST(){
    echo "I could not find that service. What would you like today?"
    echo "$SERVICE_LIST"
    read SERVICE_ID_SELECTED
    if [[ $SERVICE_ID =~ $SERVICE_ID_SELECTED ]]
    then
        SERVICES_IN_LIST
    else
        SERVICES_NOT_IN_LIST    
    fi
}

SERVICES_MENU
