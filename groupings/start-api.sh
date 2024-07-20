#!/bin/bash

# start-api.sh - Parse the vault secret and start the app

# The vault json with the password is parsed here rather than on the localhost
# to ensure that the jq command is available.

export GROUPER_API_PASSWORD=$(echo "${VAULT_SECRET_JSON}" | jq -r ".data[\"$VAULT_SECRET_KEY\"]")
if [ -z "${GROUPER_API_PASSWORD}" ] || [ "${GROUPER_API_PASSWORD}" == "null" ]; then
    echo "Error: Failed to parse Grouper API password from JSON. Exiting..."
    echo "more info:"
    echo " - VAULT_SECRET_KEY : ${VAULT_SECRET_KEY}"
    echo " - VAULT_SECRET_JSON: ${VAULT_SECRET_JSON}"
    exit 1
fi

# Start the Spring Boot application.
cd groupings
./mvnw spring-boot:run
