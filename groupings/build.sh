#!/bin/bash

# build.sh - deploy groupings containers with hot source code syncing
#
# It all begins here. The Build script requests user input in order to populate
# the environment variables and then invokes docker-compose to begin building
# the Vault and Groupings stacks.
#
# The bash file will check ui directory that user provides
# and decide which docker compose file will be used: angular or react
#
# The build process will create the Vault and Groupings images and put them
# into their respective stacks.

# Vault access
export VAULT_URL="http://localhost:8200/ui"
export VAULT_SECRET_URL="http://localhost:8200/v1/cubbyhole/uhgroupings"
export VAULT_SECRET_KEY="grouperClient.webService.password"

# Function: check the Vault status.
check_vault_status() {
    local http_status

    http_status=$(curl -s -o /dev/null -w "%{http_code}" -I "{$VAULT_URL}")

    if [ "$http_status" -eq 307 ]; then
      echo "Success: the project vault container is running."
    else
      echo "Error: the project vault is NOT available. Review the /vault README. Exiting..."
      exit 1
    fi
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

# Function: Detect UI project type (Spring Boot or Node.js)
get_ui_project_type() {
    local ui_dir=$1
    
    if [[ -f "${ui_dir}/package.json" || -f "${ui_dir}/package-lock.json" ]]; then
        echo "node"
    elif [[ -f "${ui_dir}/pom.xml" ]]; then
        echo "spring"
    else
        echo "Error: Could not determine UI project type. Neither package.json/package-lock.json nor pom.xml found. Exiting..."
        exit 1
    fi
}

echo "-------------------------------------------------------------------------"
echo "The Vault container must be running to deploy the Groupings containers."

check_vault_status

echo "-------------------------------------------------------------------------"
echo "To hot sync localhost source code changes into the containers, provide"
echo "the paths to your project directories. They are required to hot sync"
echo "localhost source code changes into the containers."
echo "-------------------------------------------------------------------------"

# To match environment variables between MacOS and WindowsOS
export USERPROFILE=${HOME}
echo "Info: USERPROFILE environment variable is set to HOME"
export USERNAME=${USER}
echo "Info: USERNAME environment variable is set to USER"

# Set GROUPINGS_API_DIR directory path.
echo "Provide the absolute paths to the Maven wrapper directories:"
set_mvnw_var "GROUPINGS_API_DIR"

# Set GROUPINGS_UI_DIR directory path.
echo "Provide the absolute path to the UI directory:"
set_path_var "GROUPINGS_UI_DIR"

# Detect UI project type and use appropriate compose file
ui_type=$(get_ui_project_type "$GROUPINGS_UI_DIR")
if [ "$ui_type" = "node" ]; then
    compose_file="docker-compose-react.yml"
else
    compose_file="docker-compose-angular.yml"
fi

# Build/rebuild and deploy the images.
echo "Building and deploying the Grouping API container using $compose_file..."
docker-compose -f "$compose_file" up --build -d

if [ $? -eq 0 ]; then
    echo "Success: Groupings images built, stack and containers deployed"
else
    echo "Error: Review the logs, review the README, etc"
    exit 1
fi

exit 0
