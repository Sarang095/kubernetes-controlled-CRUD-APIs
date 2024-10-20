#!/bin/bash

IMAGE_NAME="jenkins/jenkins:lts-jdk17"  # Change this to your Jenkins image name

# Check if the Jenkins container is running by looking for the image name in the output of docker ps
if ! docker ps --format '{{.Image}}' | grep -q "$IMAGE_NAME"; then
    echo "Jenkins container is not running. Starting it..." >> ~/check_jenkins.log
    # Run the Jenkins container
    docker run -d -p 8080:8080 -p 50000:50000 --restart=on-failure "$IMAGE_NAME" >> ~/check_jenkins.log 2>&1
else
    echo "Jenkins container is running." >> ~/check_jenkins.log
fi

