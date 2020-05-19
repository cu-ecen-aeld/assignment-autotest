# See https://docs.docker.com/engine/reference/builder/#from
# and https://hub.docker.com/_/ubuntu/
# Use the docker hub ubuntu image version 18.04
FROM ubuntu:18.04

# See https://docs.docker.com/engine/reference/builder/#copy
# All files in the current directory should be copied to
# the WORKDIR assignment-testing directory
COPY . assignment-testing

# See https://docs.docker.com/engine/reference/builder/#volume
# Create a mount point on our virtual machine for persistent data
# We will direct this to the source code we wish to test when
# starting the container
VOLUME /test-source
