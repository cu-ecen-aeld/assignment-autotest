#!/bin/bash
# Common buildroot based build script
# Run this script using `. ./buildroot-common-build.sh` after sourcing the assignment helper script
# from this directory or one with necessary functions:
#   add_validate_error
#   validate_buildroot_config
#   before_script
# Before sourcing this script, ensure you have changed directory to the root of the buildroot
# build directory (which includes build.sh script)

ROOTFS_PATH=$1

# # Remove config if it exists, to clear any previous partial runs
# rm -rf build/conf

# Add check for openssh inclusion in meta-aesd/recipes-aesd-assignments/images/core-image-aesd.bb
echo "Validating openssh has been included as a package in core-image-aesd.bb"
grep "openssh" meta-aesd/recipes-aesd-assignments/images/core-image-aesd.bb
rc=$?
if [ $rc -ne 0 ]; then
	add_validate_error "openssh package not added in core-image-aesd.bb"
	echo "Adding openssh package in core-image-aesd.bb"
	echo "CORE_IMAGE_EXTRA_INSTALL += \" openssh\"" >> meta-aesd/recipes-aesd-assignments/images/core-image-aesd.bb
fi

# Validate if ssh link is used
echo "validating ssh has been used as the git repository url link in aesd-assignments_git.bb"
grep "^SRC_URI[[:space:]].*=[[:space:]].*https" meta-aesd/recipes-aesd-assignments/aesd-assignments/aesd-assignments_git.bb
rc=$?
if [ $rc -eq 0 ]; then
	add_validate_error "Using https instead of ssh URL on aesd-assignments, will not build automated"
	echo "Replacing https by ssh in aesd-assignments_git.bb"
	sed -i 's/^SRC_URI[[:space:]].*=[[:space:]].*https:\/\/github.com\//SRC_URI = "git:\/\/git@github.com\//g' meta-aesd/recipes-aesd-assignments/aesd-assignments/aesd-assignments_git.bb
	sed -i 's/protocol=https/protocol=ssh/g' meta-aesd/recipes-aesd-assignments/aesd-assignments/aesd-assignments_git.bb
	sed -i 's/branch.*/branch=master"/g' meta-aesd/recipes-aesd-assignments/aesd-assignments/aesd-assignments_git.bb
fi

# Validate if aesd-assignments package has been added in "meta-aesd/recipes-aesd-assignments/images/core-image-aesd.bb"
echo "Validating aesd-assignments package has been added in core-image-aesd.bb"
grep "#IMAGE_INSTALL_append = \" aesd-assignments\"" meta-aesd/recipes-aesd-assignments/images/core-image-aesd.bb
rc=$?
if [ $rc -eq 0 ]; then
	add_validate_error "aesd-assignments package not added in core-image-aesd.bb"
	echo "Adding aesd-assignments package in core-image-aesd.bb"
	sed -i 's/#IMAGE_INSTALL_append[[:space:]]=[[:space:]]"[[:space:]]aesd-assignments"/IMAGE_INSTALL_append = " aesd-assignments"/g' meta-aesd/recipes-aesd-assignments/images/core-image-aesd.bb
fi

# Validating if build.sh has executable permissions
if [ ! -x build.sh ]; then
	add_validate_error "build.sh is not executable"
	echo "Setting executable permission for build.sh"
	chmod a+x build.sh
fi

# # Validating check for runquemu.sh as per the error in assignment document
# if [ ! -e runqemu.sh ]; then
# 	if [ -e runquemu.sh ]; then
# 		echo "Moving runquemu.sh to runqemu.sh due to problem with assignment document"
# 		mv runquemu.sh runqemu.sh
# 	fi
# fi

# Validate if runqemu exists and has executable permissions
echo "Validating runqemu.sh exists and has executable permissions"
if [ ! -e runqemu.sh ]; then
	add_validate_error "runqemu.sh does not exist"
	echo "Creating runqemu.sh and setting executable permissions for runqemu.sh"
	# Creating runqemu inside the repository.
	echo "Creating runqemu.sh inside the student's repository"
	echo '#!/bin/bash' > runqemu.sh
	echo "source poky/oe-init-build-env" >> runqemu.sh
	echo "runqemu nographic" >> runqemu.sh
	chmod a+x runqemu.sh
else
	if [ ! -x runqemu.sh ]; then
		add_validate_error "runqemu.sh is not executable"
		echo "Setting executable permissions for runqemu.sh"
		chmod a+x runqemu.sh
	fi
fi

# Validating correct buildroot configuration
# validate_buildroot_config

#Adding latest runqemu from ${script_dir} to current directory for SPRING 2020 modification.
cp ${script_dir}/runqemu.sh .
cp ${script_dir}/build.sh .

# Setup keys
before_script

# Deploying build and executing test cases if successful
echo "Running build.sh"
./build.sh
rc=$?
if [ $rc -eq 0 ]; then
	build_success_status=0			#0 indicates true
fi

sleep 5s

# Validating if aesdsocket-start-stop is in /etc/init.d and aesdsocket is in /usr/bin
ROOTFS_PATH=build/tmp/work/qemuarm64-poky-linux/core-image-aesd/1.0-r0/rootfs

if [[ -e ${ROOTFS_PATH}/etc/init.d/aesdsocket-start-stop || -e ${ROOTFS_PATH}/etc/init.d/aesdsocket-start-stop.sh ]]; then
	echo "aesdsocket-start-stop/aesdsocket-start-stop.sh exists"
else
	add_validate_error "aesdsocket-start-stop/aesdsocket-start-stop.sh script not found in /etc/init.d"
	# If aesdsocket-start-stop script is not found here, aesdsocket executable would not execute on startup. Following error checks may fail.
	# But in order to handle this a validate_socket_daemon is executed on qemu startup where if the aesdsocket does not execute on boot up
	# It will log an error and start the aesdsocket executable manually
fi

if [ ! -e ${ROOTFS_PATH}/usr/bin/aesdsocket ]; then
	add_validate_error "aesdsocket executable not found in /usr/bin"
	aesdsocket_not_found=0			#0 indicates true
else
	echo "aesdsocket executable already exists"
fi

#if [ $build_again -eq 0 ]; then
	# Deploying build and executing test cases if successful
#	ec# Validating if aesdsocket-start-stop is in /etc/init.d and aesdsocket is in /usr/bin
# ROOTFS_PATH=build/tmp/work/qemuarm64-poky-linux/core-image-aesd/1.0-r0/rootfs

if [[ -e ${ROOTFS_PATH}/etc/init.d/aesdsocket-start-stop || -e ${ROOTFS_PATH}/etc/init.d/aesdsocket-start-stop.sh ]]; then
	echo "aesdsocket-start-stop/aesdsocket-start-stop.sh exists"
else
	add_validate_error "aesdsocket-start-stop/aesdsocket-start-stop.sh script not found in /etc/init.d"
	# If aesdsocket-start-stop script is not found here, aesdsocket executable would not execute on startup. Following error checks may fail.
	# But in order to handle this a validate_socket_daemon is executed on qemu startup where if the aesdsocket does not execute on boot up
	# It will log an error and start the aesdsocket executable manually
fi

if [ ! -e ${ROOTFS_PATH}/usr/bin/aesdsocket ]; then
	add_validate_error "aesdsocket executable not found in /usr/bin"
	aesdsocket_not_found=0			#0 indicates true
else
	echo "aesdsocket executable already exists"
fi

sleep 5s

if [ $build_success_status -ne 0 ]; then
	add_validate_error "build script failed with error $build_success_status"
else

	if [ $aesdsocket_not_found -ne 0 ]; then
		ssh-keygen -f "/root/.ssh/known_hosts" -R "[localhost]:10022"
		
		# Running qemu instance in background
		validate_qemu

		# Validate if program runs as a daemon
		validate_socket_daemon

		# Validating Socket functionality: Single thread, Multithreaded and timer functionality.
		# aesdsocket should be running at this point before calling this function
		validate_socket ${script_dir}

		# Validate Socket functionality for long string
		#validate_socket_long_string ${script_dir}

		# Validating if signal handler is implemented correctly and program exits gracefully deleting the /tmp/aesdsocketdata file.
		# aesdsocket should be running at this point before calling this function
		validate_signal_handlers
				
		# Validating bind error. 
		# aesdsocket should not be running at this point before calling this function
		#validate_error_checks

		#Killing qemu instance to return to host terminal
		echo "Killing qemu"
		killall qemu-system-aarch64
	else
		add_validate_error "runqemu.sh, daemon validation, signal_handler validation not executed since aesdsocket executable not found in /usr/bin"
	fi
fi

# This sleep is required or gives bind error
echo "Sleeping for 60s before checking for memory leaks"
sleep 60s

# Validating if Wall and Werror flags are present in Makefile
validate_makefile_flags
# Validating if makefile can create an executable successfully and valgrind test can be implemented.
# validate_makefile_and_memoryleak ${script_dir}