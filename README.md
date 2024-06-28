**_This project is purely experimental at this point._**

# Overview

Use docker to develop the UH Groupings project on a locahost environment.

The docker stack contains the following:

1) Hashicorp vault container to secure the Grouper API password.
2) Groupings API container featuring hot updates.
3) Groupings UI container featuring hot updates.

Anticipate localhost tools:

1) docker desktop (and a Docker Hub account)

# Setting Up

## Linux/macOS/Windows

Download the project.

    mkdir gitclone
    cd gitclone
    git clone https://github.com/uhawaii-system-its-ti-iam/hashicorp-vault-docker-image.git

## Set up the vault

The vault must be set up and the Grouper API password added to it before the 
Groupings containers are created.

    cd vault

And review the README provided.

## Set up the Groupings API and UI

    cd groupings

And review the README provided.
