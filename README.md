# Table of Contents
<!-- TOC -->
* [Overview](#overview)
  * [Anticipated localhost Tool(s)](#anticipated-localhost-tools)
  * [Questions and Answers](#questions-and-answers)
  * [Warning for Windows Users](#warning-for-windows-users)
* [Setting Up](#setting-up)
  * [Spring Boot Hot Updates with DevTools](#spring-boot-hot-updates-with-devtools)
    * [DevTools Key Features](#devtools-key-features)
    * [Enable DevTools](#enable-devtools)
  * [Linux/macOS/Windows](#linuxmacoswindows)
  * [Set up the vault](#set-up-the-vault)
  * [Set up the Groupings API and UI](#set-up-the-groupings-api-and-ui)
* [TODOs](#todos)
  * [Describe how best to handle password changes.](#describe-how-best-to-handle-password-changes)
<!-- TOC -->

# Overview

Use docker to develop the UH Groupings project on a locahost environment.

The docker stack contains the following:

1) Hashicorp vault container to secure the Grouper API password.
2) Groupings API container featuring hot updates.
3) Groupings UI container featuring hot updates.

## Work Remaining
For this project the following work remains to be done:
1) Determine what should be moved from the overrides file to the Vault, and test.
2) Determine how best to update the pom file for hot updates, and test.

## Anticipated localhost Tool(s)

- Docker Desktop (and a Docker Hub account)

## Questions and Answers

Is the overrides file still relevant? 
- Yes. It overrides properties without the danger of the changes ending up in a PR.

# Setting Up

## Spring Boot Hot Updates with DevTools

Hot Updates to the source code can be sync'ed to the running container and 
force the app in the container to be restarted. Spring Boot must be configured
appropriately to enable hot updates.

This is possible because the containers mount your source directories on your
localhost. The purpose of the containers is simply to run the projects.

### DevTools Key Features

- Automatic Restart: DevTools monitors for any changes in your classpath and 
automatically restarts your Spring Boot application.
- Live Reload: This feature allows you to refresh your browser automatically 
whenever there are changes detected to resources.
- Remote Development: It can also be configured to work with applications 
running in containers.

### Enable DevTools

_(enabling DevTools is optional)_

Add to Maven pom.xml:

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
    </dependencies>

Add to dockerhost properties file:

    # Enable automatic restart
    spring.devtools.restart.enabled=true
    # Disable template caches
    spring.thymeleaf.cache=false

It may be necessary to add the following to the dockerhost properties file in
order to ensure that hot reloading to the container works as expected.

    spring.devtools.restart.polling-interval=1000
    spring.devtools.restart.trigger-file=/.trigger

## Linux/macOS/Windows

1. Install Docker Desktop (optional)

2. Download the project


    mkdir gitclone
    cd gitclone
    git clone https://github.com/uhawaii-system-its-ti-iam/uh-groupings-docker-dev.git
    cd uh-groupings-docker-dev

## Set up the vault

The vault must be set up and the Grouper API password added to it before the
Groupings containers are created.

    cd vault

And review the README provided.

## Set up the Groupings API and UI

    cd groupings

And review the README provided.

# TODOs

## Describe how best to handle password changes.
