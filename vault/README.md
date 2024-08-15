# Table of Contents

<!-- TOC -->
* [Table of Contents](#table-of-contents)
* [Overview](#overview)
* [Installation](#installation)
  * [Vault Setup and Startup](#vault-setup-and-startup)
  * [Store the Grouper API Password](#store-the-grouper-api-password)
    * [Manually](#manually)
    * [With the web service](#with-the-web-service)
* [Troubleshooting](#troubleshooting)
  * [version is obsolete](#version-is-obsolete)
  * [vault Error Head](#vault-error-head)
  * [connection refused](#connection-refused)
  * [vault needs to be reinitialized](#vault-needs-to-be-reinitialized)
<!-- TOC -->

# Overview

Deploy a docker container on a development localhost environment to run 
HashCorp Vault to contain secrets for a containerized UH Groupings development
instance.

Implement a vault under the developer home directory to persistently store the 
Grouper API password used by the UH Groupings API. When the developer attempts 
to run the containerized UH Groupings project the vault will supply the 
password.

## Reminder to unseal the vault

Each time the vault container is restarted the vault will need to be unsealed. 
The unseal key and the token root token will be needed:

- http://localhost:8200/ui/vault/unseal

# Installation

Prep environment, start container.

  For Windows, the chmod step is not applicable.

    cd uh-groupings-docker-dev/vault
    chmod +x build.sh
    ./build.sh  (Mac)
    ./build.ps1 (Windows)

## Vault Setup and Startup

- For development only 1 unseal key is required, rather than the usual 2-3.
- The vault needs to be unsealed upon initialization, after a service restart,
or if it has been manually sealed.
- The vault must be unsealed before the UI will be operational.
- The root token is not required to add and access secrets. It is used to 
configure the vault, set up policies, enable authentication methods and secret 
engines.

The following can be executed from within docker desktop. 
- navigate to the "containers" menu
- select the stack "hashicorp-vault-docker-image"
- expand it in order to select the image "groupings-vault". 
- the "Logs" menu is the default, select the "Exec" menu to access the 
container's command prompt enter the following:


    vault operator init -key-shares=1 -key-threshold=1
    vault operator unseal <Unseal_Key>

_Be sure to save the unseal key and root token for later use._

## Store the Grouper API Password

Important vault values for here and in the scripts:

- Vault path:   "/cubbyhole/uhgroupings"
- Password key: "grouperClient.webService.password"
- Vault UI:     "http://localhost:8200"
- Vault URL:    "http://localhost:8200/v1/cubbyhole/uhgroupings"

### Manually

(replace "sample_password" with the actual grouper test API password)

    vault login
    vault write cubbyhole/uhgroupings grouperClient.webService.password=sample_password -format=json
    vault read -format=json cubbyhole/uhgroupings

### With the web service

- Navigate to http://localhost:8200/ui/vault/dashboard
- Use the root token to log in.

# Troubleshooting

## version is obsolete

    WARN[0000] .../hashicorp-vault-docker-image/docker-compose.yml: `version` is obsolete

Docker Compose v2 warns that the version setting is obsolete. Remove it from the docker-compose file.

## vault Error Head

    vault Error Head "https://registry-1.docker.io/v2/library/vault/manifests/latest": unauth...

You must have a dockerhub access token in order to download docker images from Docker Hub.

## connection refused

    operator init -key-shares=1 -key-threshold=1
    Get "http://127.0.0.1:8200/v1/sys/seal-status": dial tcp 127.0.0.1:8200: connect: connection refuse

## vault needs to be reinitialized

This requires starting over.

1) Stop the container
2) Delete the vault data (see below)
3) Start the container
4) Initialize the vault


    rm -rf ${HOME}/.vault/uhgroupings/data/*
