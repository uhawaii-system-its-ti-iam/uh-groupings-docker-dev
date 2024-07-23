# Table of Contents
<!-- TOC -->
* [Overview](#overview)
* [Setting Up](#setting-up)
  * [Spring Boot Hot Updates with DevTools](#spring-boot-hot-updates-with-devtools)
    * [DevTools Key Features](#devtools-key-features)
    * [Enable DevTools](#enable-devtools)
  * [Linux/macOS/Windows](#linuxmacoswindows)
  * [Set up the vault](#set-up-the-vault)
  * [Set up the Groupings API and UI](#set-up-the-groupings-api-and-ui)
<!-- TOC -->

# Overview

Use docker to develop the UH Groupings project on a locahost environment.

The docker stack contains the following:

1) Hashicorp vault container to secure the Grouper API password.
2) Groupings API container featuring hot updates.
3) Groupings UI container featuring hot updates.

Anticipated localhost tools:

1) Docker Desktop (and a Docker Hub account)

**Is the overrides file still relevant?**
  Yes. It overrides properties without the danger of the changes ending up in a PR.

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

Add to localhost properties file:

    # Enable automatic restart
    spring.devtools.restart.enabled=true
    # Disable template caches
    spring.thymeleaf.cache=false

It may be necessary to add the following to the localhost properties file in
order to ensure that hot reloading to the container works as expected.

    spring.devtools.restart.polling-interval=1000
    spring.devtools.restart.trigger-file=/.trigger

## Linux/macOS/Windows

Install Docker Desktop (optional).

Download the project (shell commands):

    mkdir gitclone
    cd gitclone
    git clone https://github.com/uhawaii-system-its-ti-iam/uh-groupings-docker-dev.git
    cd uh-groupings-docker-dev

## Set up the vault

The vault must be set up and the test Grouper API password added to it before  
the Groupings containers are created.

    cd vault

And review the README provided.

## Set up the Groupings API and UI

    cd groupings

And review the README provided.
