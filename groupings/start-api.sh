#!/bin/bash

# start-api.sh - Parse the vault secret and start the Groupings API

# The vault's json data with the password is parsed in the container rather than
# on the localhost to ensure that the jq command is available.

# WARNING: the name of the following environment variable must align with class
#          GrouperPropertyConfigurer.java in the API project.

export GROUPERCLIENT_WEBSERVICE_PASSWORD=$(echo "${VAULT_SECRET_JSON}" | jq -r ".data[\"$VAULT_SECRET_KEY\"]")
if [ -z "${GROUPERCLIENT_WEBSERVICE_PASSWORD}" ] || [ "${GROUPERCLIENT_WEBSERVICE_PASSWORD}" == "null" ]; then
    echo "Error: Failed to parse Grouper API password from JSON. Exiting..."
    echo "more info:"
    echo " - VAULT_SECRET_KEY : ${VAULT_SECRET_KEY}"
    echo " - VAULT_SECRET_JSON: ${VAULT_SECRET_JSON}"
    exit 1
fi

# Start the Spring Boot application.
cd groupings

./mvnw spring-boot:run
