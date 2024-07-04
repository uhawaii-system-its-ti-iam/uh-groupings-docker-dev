#!/bin/sh

# build.sh - initialize for running vault.

# Check if HOME environment variable is not set.
if [ -z "${HOME}" ]; then
  echo "Error: the HOME environment variable is not set."
  exit 1
fi

# Create the necessary directories for vault data and configuration.
mkdir -pv ${HOME}/.vault/uhgroupings/data
mkdir -pv ${HOME}/.vault/uhgroupings/config

# Ensure any previous vault data is removed to ensure a fresh init.
if [ -n "$(ls -A ${HOME}/.vault/uhgroupings/data/)" ]; then
  echo "Info: removed existing vault data to ensure a fresh init."
  rm -rf ${HOME}/.vault/uhgroupings/data/*
fi

# Copy the Vault configuration file to the appropriate directory.
cp -v vault-config.hcl ${HOME}/.vault/uhgroupings/config

# Start the vault container using Docker Compose.
docker-compose up -d

# Check if vault started successfully.
if [ $? -eq 0 ]; then
  echo "Success: the vault container has started. See README for more instructions."
else
  echo "Error: failed to start the Vault container."
  exit 1
fi

exit 0
