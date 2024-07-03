#!/bin/bash

# init-build.sh - deploy groupings containers with hot source code syncing

# Vault access
SECRET_PATH="secret/uhgroupings"
export VAULT_ADDR="http://localhost:8200"
export VAULT_SECRET_KEY="grouperClient.webService.password_json"

# Function: validate and set an environment variable with the absolute /src path
set_src_var() {
    local var_name=$1
    local var_value

    read -e -p "Enter ${var_name}: " -r var_value

    if [ -z "${var_value}" ]; then
        echo "Error: ${var_name} cannot be blank. Exiting..."
        exit 1
    elif [[ ! "${var_value}" =~ /src$ ]]; then
        echo "Error: The path must end with '/src'. Exiting..."
        exit 1
    elif [[ ! -d "${var_value}" ]]; then
        echo "Error: The directory ${var_value} does not exist. Exiting..."
        exit 1
    fi

    export "${var_name}=${var_value}"
}

# Function: get the vault secret.
set_token_var() {
    local var_name=$1
    local var_value

    read -e -p "Enter ${var_name}: " -r var_value

    if [ -z "${var_value}" ]; then
        echo "Error: ${var_name} cannot be blank. Exiting..."
        exit 1
    fi
    export "${var_name}=${var_value}"
}

# Function: get the Grouper API password_json data from the vault.
set_password_json_var() {
    local var_name=$1
    local password_json

    password_json=$(curl --header "X-Vault-Token: ${VAULT_TOKEN}" \
                         --request GET "${VAULT_ADDR}/v1/${SECRET_PATH}" \
                         --silent)

    if [ $? -ne 0 ]; then
        echo "Error: Failed to communicate with Vault. Exiting..."
        exit 1
    fi

    if [ -z "${password_json}" ]; then
        echo "Error: Failed to retrieve data from Vault. Exiting..."
        exit 1
    fi

    export "${var_name}=${password_json}"
}

echo "-------------------------------------------------------------------------"
echo "To hot sync localhost source code changes into the containers, provide"
echo "the paths to your project /src directories. They are required to hot sync"
echo "localhost source code changes into the containers."
echo ""
echo " *** An absolute path is required and must end with /src ***"
echo "-------------------------------------------------------------------------"

# Set GROUPINGS_API_SRC
set_src_var "GROUPINGS_API_SRC"

# Set GROUPINGS_UI_SRC
set_src_var "GROUPINGS_UI_SRC"

echo "Provide the vault token for opening the vault:"

# Set VAULT_TOKEN
set_token_var "VAULT_TOKEN"

echo "Retrieving Grouper API password from the vault..."

# Get and set the Grouper API password_json.
set_password_json_var "VAULT_SECRET_JSON"

echo "Building and deploying the Grouping API container..."

# Build/rebuild and deploy the images.
docker-compose up --build -d
if [ $? -eq 0 ]; then
    echo "Success: Images built, containers deployed"
else
    echo "Error: Review the logs"
fi

exit 0
