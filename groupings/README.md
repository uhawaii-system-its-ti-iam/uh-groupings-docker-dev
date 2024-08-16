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

1. The groupings API and UI projects must already be cloned to the localhost.
2. The localhost Vault container must be running and contain the Groupings API password. See the vault README for details.

# Installation

Deploy the containers.

    cd uh-groupings-docker-dev/groupings
    chmod +x build.sh (Mac)
    ./build.sh  (Mac)
    ./build.ps1 (Windows)

## Spring Boot Profiles

localhost vs dockerhost

The containerized UI project requires the "dockerhost" profile in order to 
connect to the containerized API. The containerized API project works fine with
the "localhost" profile.

## Browser Access to the Containerized Grouping UI

Use your docker desktop client to check that the Grouper containers are 
running. Enter the following URL into your browser:

    http://localhost:8080/uhgroupings/
