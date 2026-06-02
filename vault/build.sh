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

# Vault data under ~/.vault/uhgroupings/data is persisted across runs.
# To wipe storage and start over, use ./reset-vault.sh from this directory.

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
