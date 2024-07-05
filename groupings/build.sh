#!/bin/bash

# build.sh - deploy groupings containers with hot source code syncing

# Vault access
SECRET_PATH="secret/uhgroupings"
export VAULT_ADDR="http://localhost:8200"
export VAULT_SECRET_KEY="grouperClient.webService.password"

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

# Function: validate and set an environment variable with the Maven directory
# path.
set_mvnw_var() {
     local var_name=$1
     local var_value

     read -e -p "Enter ${var_name}: " -r var_value

     if [ -z "${var_value}" ]; then
         echo "Error: ${var_name} cannot be blank. Exiting..."
         exit 1
     elif [[ ! -d "${var_value}" ]]; then
         echo "Error: The directory ${var_value} does not exist. Exiting..."
         exit 1
     elif [[ ! -f "${var_value}/mvnw" ]]; then
         echo "Error: The file 'mvnw' does not exist in the directory ${var_value}. Exiting..."
         exit 1
     fi

     export "${var_name}=${var_value}"
}

# Function: validate and set an environment variable with a directory path.
set_path_var() {
    local var_name=$1
    local var_value

    read -e -p "Enter ${var_name}: " -r var_value

    if [ -z "${var_value}" ]; then
        echo "Error: ${var_name} cannot be blank. Exiting..."
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

echo "-------------------------------------------------------------------------"
echo "To hot sync localhost source code changes into the containers, provide"
echo "the paths to your project directories. They are required to hot sync"
echo "localhost source code changes into the containers."
echo "-------------------------------------------------------------------------"

# Set GROUPINGS_OVERRIDES directory path.
echo "Provide the absolute path to the overrides file directory:"
set_path_var "GROUPINGS_OVERRIDES"

# Set GROUPINGS_API_DIR directory path.
Echo "Provide the absolute path to the Maven wrapper:"
set_mvnw_var "GROUPINGS_API_DIR"

# Set GROUPINGS_UI_DIR directory path.
set_mvnw_var "GROUPINGS_UI_DIR"

# Set VAULT_TOKEN value.
echo "Provide the vault token for opening the vault:"
set_token_var "VAULT_TOKEN"

# Get and set the Grouper API password_json.
echo "Retrieving Grouper API password from the vault..."
set_password_json_var "VAULT_SECRET_JSON"

# Build/rebuild and deploy the images.
echo "Building and deploying the Grouping API container..."
docker-compose up --build -d
if [ $? -eq 0 ]; then
    echo "Success: Images built, containers deployed"
else
    echo "Error: Review the logs"
fi

exit 0
