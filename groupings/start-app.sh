#!/bin/bash

# start-app.sh - Set up secrets and start the app

# The json with the password is parsed here rather than on the localhost to
# ensure that the jq command is available.

export GROUPER_API_PASSWORD=$(echo "${VAULT_SECRET_JSON}" | jq -r ".data.data[\"$VAULT_SECRET_KEY\"]")
if [ -z "${GROUPER_API_PASSWORD}" ]; then
    echo "Error: Failed to parse Grouper API password from JSON. Exiting..."
    exit 1
fi

# Start the Spring Boot application.
./mvnw spring-boot:run
