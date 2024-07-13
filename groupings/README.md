Deploy development containers for the UH Groupings project. Container 
deployment is designed to enable hot reloading. The Grouper API
password is obtained from the Vault container that must be deployed
first.

Hot Reloading: Tools like Spring Boot’s DevTools detect changes to the files in
the /src directory (thanks to the mounted volume) and automatically reload the
application or the relevant parts of it. This eliminates the need to manually
restart the Docker container or rebuild the image to see code changes take 
effect.

## Prerequisites

The localhost Vault container must be running and contain the Groupings API
password. See the vault README for details.

## Linux/macOS/Windows

Download the groupings API project.

    mkdir gitclone
    cd gitclone
    git clone https://github.com/uhawaii-system-its-ti-iam/hashicorp-vault-docker-image.git

 Deploy the containers (for Windows there is a Powershell script).

    cd hashicorp-vault-docker-image/vault
    chmod +x build.sh
    ./build.sh
