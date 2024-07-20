#!/bin/bash

# build.sh - deploy groupings containers with hot source code syncing

# Vault access
export VAULT_URL="http://localhost:8200/v1/cubbyhole/uhgroupings"
export VAULT_SECRET_KEY="grouperClient.webService.password"

# Function: get the Grouper API password data from the vault.
set_password_json_var() {
    local var_name=$1
    local password_json
    local curl_command

    echo "Retrieving password from Vault..."

    # Assemble curl command as a string
    curl_command="curl --header \"X-Vault-Token: ${VAULT_TOKEN}\" \
  --header \"Accept: application/json\" \
  --request GET \"${VAULT_URL}\" \
  --silent --show-error"

    # Execute curl command with eval
    password_json=$(eval "${curl_command}")

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

# Function: validate and set an environment variable with the Maven wrapper
# directory path.
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
        echo "Error: vault secret not found, review the README. Exiting..."
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
    echo "Error: Review the logs, review the README, etc"
fi

exit 0
