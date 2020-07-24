# See https://docs.docker.com/engine/reference/builder/#from
# and https://hub.docker.com/_/ubuntu/
# Use the docker hub ubuntu image version 18.04
FROM ubuntu:18.04 AS aesd-build

RUN export UBUNTU_FRONTEND=noninteractive

RUN apt-get update && apt-get install apt-utils -y
RUN apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/America/Denver /etc/localtime 
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update && apt-get install dialog -y
RUN apt-get update && apt-get install build-essential -y
RUN apt-get update && apt-get install netcat iputils-ping -y
RUN apt-get update && apt-get install psmisc -y



# Buildroot requirements for assignments 4 and later
RUN apt-get update && apt-get install -y sed make binutils build-essential bash patch gzip bzip2 perl tar cpio unzip rsync file bc wget python libncurses5-dev git qemu
RUN apt-get update && apt-get install -y openssh-client
RUN apt-get update && apt-get install -y expect
RUN apt-get update && apt-get install -y sshpass

# Yocto requirements for assignment 6
RUN apt-get update && apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib
RUN apt-get update && apt-get install -y build-essential chrpath socat cpio python python3 python3-pip python3-pexpect
RUN apt-get update && apt-get install -y xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev xterm locales
RUN apt-get update && apt-get install -y valgrind
RUN apt-get update && apt-get install -y sudo

RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ARG USER_ID
ARG GROUP_ID
#See https://askubuntu.com/a/1168971
#Creating a new user admin and adding into sudoers group with no password
#Installing sudo package since sudo does not work
#Use the group and user id for the current user to avoid permission problems with created files
RUN echo "Creating admin user with user id ${USER_ID} and group id ${GROUP_ID}" && \
	groupadd -g ${GROUP_ID} admin && \
	adduser --uid ${USER_ID} --gid ${GROUP_ID} --disabled-password --gecos '' admin && \
	adduser admin sudo && \
	echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER admin

# Add ssh key based on private key arg
RUN mkdir -p /home/admin/.ssh
ARG SSH_PRIVATE_KEY
RUN echo "${SSH_PRIVATE_KEY}" > /home/admin/.ssh/id_rsa_docker_ro && chmod 400 /home/admin/.ssh/id_rsa_docker_ro

# Add github to known hosts so we don't get prompted to allow ssh key use there
RUN touch /home/admin/.ssh/known_hosts
RUN ssh-keyscan github.com >> /home/admin/.ssh/known_hosts
# See https://docs.docker.com/engine/reference/builder/#copy
# All files in the current directory should be copied to
# the WORKDIR assignment-testing directory
COPY . assignment-testing

