#! /bin/bash

# Connect to the database
PSQL="psql -U freecodecamp -d salon -t -c"

# Function to display services
display_services() {
    echo -e "\nWelcome to the salon! Here are our services:"
    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    echo "$SERVICES" | while read SERVICE_ID BAR NAME; do
        # Trim whitespace from service name
        NAME=$(echo "$NAME" | xargs)
        echo "$SERVICE_ID) $NAME"
    done
}

# Display services initially
display_services

# Service selection loop
while true; do
    echo -e "\nPlease select a service by entering its number:"
    read SERVICE_ID_SELECTED

    # Check if service exists and trim whitespace
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    SERVICE_NAME=$(echo "$SERVICE_NAME" | xargs)  # Trim whitespace

    if [[ -z $SERVICE_NAME ]]; then
        echo "That service does not exist. Please try again."
        display_services
    else
        break
    fi
done

# Get customer phone number
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# New customer handling
if [[ -z $CUSTOMER_ID ]]; then
    echo -e "\nWe don't have you in our system. Please enter your name:"
    read CUSTOMER_NAME

    # Insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

# Get appointment time
echo -e "\nPlease enter the time for your appointment (e.g., 10:30):"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Retrieve and trim customer name
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | xargs)  # Trim whitespace

# Display confirmation and exit
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
exit 0
