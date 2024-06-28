#!/bin/bash

# init-build.sh - deploy groupings containers with hot source code syncing

# Function: validate and set an environment variable with the absolute /src path
set_src_var() {
    local var_name=$1
    local var_value

    # Prompt user
    read -e -p "Enter ${var_name}: " -r var_value

    # Validate input
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

    # Set the environment variable.
    export "${var_name}=${var_value}"
}

echo "-------------------------------------------------------------------------"
echo "To hot sync localhost source code changes into the containers, provide"
echo "the paths to the project /src directories. They are required to hot sync"
echo "localhost source code changes into the containers."
echo ""
echo " *** An absolute path is required and must end with /src ***"
echo "-------------------------------------------------------------------------"
echo "init-build: 1) Set the API src var, 2) Set the UI src var, 3) Build image & deploy container"

# Set GROUPINGS_API_SRC
set_src_var "GROUPINGS_API_SRC"
echo "1) Success"

# Set GROUPINGS_UI_SRC
set_src_var "GROUPINGS_UI_SRC"
echo "2) Success"

# Build/rebuild and deploy the images.
docker-compose up --build -d
if [ $? -eq 0 ]; then
    echo "3) Success: Images built, containers deployed"
else
    echo "3) Error: Review the logs"
fi
