#!/bin/sh

cd `dirname $0`
. ./script-helpers
. ./assignment-timeout
. ./assignment-3-checks

scriptsdir=`pwd`
cd ../../../

# For run within the docker container, to ensure we have acces to crosstool-ng tools
export PATH="/home/autotest-admin/x-tools/arm-unknown-linux-gnueabi/bin:${PATH}"

cdir=`pwd`
OUTDIR=${cdir}/aesd-build 
mkfifo /tmp/guest.in /tmp/guest.out
manual_linux_success_flag=0		#This flag signifies atleast one test case for manual_linux.sh has passed


#Function to check cross compile makefile functionality and execuatble creation
makefile_check

# #Replace #!/bin/bash by #!/bin/sh in tester.sh and finder.sh if found
# ##WARNING: Students might prefix sh to a file containing #!/bin/bash to make it work
# bash_to_sh "tester.sh"
# bash_to_sh "finder.sh"


#Running manual_linux.sh with already existing correct directory path as parameter
mkdir "${OUTDIR}"
echo "Running manual_linux.sh with parameter"
./manual_linux.sh "${OUTDIR}" #>/dev/null 2>&1
rc=$?
if [ $rc -ne 0 ]; then
	add_validate_error "manual_linux.sh should have exited with return value 0 if correct existing directory path was specified as a parameter"
else
	manual_linux_success_flag=1		
fi


#Running manual_linux.sh with no directory path as parameter i.e should use default directory /tmp/ecen5013
echo "Running manual_linux.sh with no parameter"
./manual_linux.sh #>/dev/null 2>&1
rc=$?
if [ $rc -ne 0 ]; then
	add_validate_error "manual_linux.sh should have exited with return value 0 if no parameters were specified"
else
	manual_linux_success_flag=2
fi


#Start qemu terminal over here
if [ $manual_linux_success_flag -eq 0 ]; then
	add_validate_error "None of the manual_linux.sh test cases have passed. Thus not running test_start_qemu_terminal.sh"		
elif [ $manual_linux_success_flag -eq 1 ]; then
	OUTDIR="${cdir}/aesd-build"
elif [ $manual_linux_success_flag -eq 2 ]; then
	OUTDIR=/tmp/ecen5013	
fi


if [ $manual_linux_success_flag -ne 0 ]; then

	#check for linux/linux-stable, rootfs and busybox directories
	#There are two url to clone for linux git repository: one clones a directory called linux and the other linux-stable.
	#Students have used either one of these.
	if [ ! -d "${OUTDIR}/linux" ] && [ ! -d "${OUTDIR}/linux-stable" ] || [ ! -d "${OUTDIR}/busybox" ] || [ ! -d "${OUTDIR}/rootfs" ]; then
		add_validate_error "${OUTDIR} has one or more missing directories: linux, linux-stable, busybox, rootfs"
	else
		echo "${OUTDIR} has all the required directories to start QEMU"
	fi


	#check for versatile-pb.dtb, zImage and initramfs.cpio.gz
	echo "Checking versatile-pb.dtb, zImage and initramsf in OUTDIR"
	qemu_boot_files_check "${OUTDIR}"

	#Checking the ownership of rootfs		###NOT WORKING FOR SOME REASON
	#rootfs_ownership_check "${OUTDIR}"

	#Checking if INSTALL_MOD_PATH has been used or not
	modules_check "${OUTDIR}"

	#Check for all the required library files.
	library_check "${OUTDIR}"

	#Checking for device nodes /dev/null and /dev/console in ${OUTDIR}/rootfs
	device_node_check "${OUTDIR}"

	#Checking executables writer, finder.sh and tester.sh are in correct location i.e ${OUTDIR}/rootfs/home
	executables_check "${OUTDIR}"

	#Find the cpio file line and force it to overwrite if it doesn't
	##WARNING: Students might employ other methods in order to overwrite the .cpio.gz file.
	#Check manually by going through the script if this validation error occurs
	echo "Checking if overwriting .cpio.gz functionality is enabled"
	overwrite_cpio_check


	#adding necessary helper scripts
	echo "Adding necessary helper scripts to the image"
	${scriptsdir}/assignment-3-test-add-scripts.sh "${OUTDIR}" #>/dev/null 2>&1
	rc=$?
	if [ $rc -ne 0 ]; then
		add_validate_error "assignment-3-test-add-scripts.sh should have exited with return value 0"
	fi


	echo "Starting QEMU"
	${scriptsdir}/test_start_qemu_terminal.sh "${OUTDIR}" &
	timeout ${qemu_timeout} ${scriptsdir}/test_qemu_data.sh
	#rc value would be 124 if read_qemu is interrupted by timeout. 0 for success
	#read_qemu getting interrupted would mean that the either manual_linux.sh does not consist of key components for qemu to boot up or test_start_qemu_terminal.sh failed.
	rc=$?	
	if [ $rc -ne 0 ]; then
		add_validate_error "test_start_qemu_terminal.sh should have exited with return value 0."
	else
		#killall does not work in docker install psmisc or use pkill
		killall qemu-system-arm
	fi

	#If the script execution has reached here, this means that atleast one of the manual_linux.sh has passed.
	#Running manual_linux.sh with script ran already once for the specified directory path as parameter
	#i.e should not clone busybox and linux_stable again.
	#Running below manual_linux.sh before test_start_qemu_terminal.sh will prevent us from testing scripts inside qemu
	#if by chance the manual_linux.sh below fails for some reason.Thus executing this test case at the last.
#	cd $1
	echo "Running manual_linux.sh with already specified parameter"
	./manual_linux.sh "${OUTDIR}" #>/dev/null 2>&1
	rc=$?
	if [ $rc -ne 0 ]; then
		add_validate_error "manual_linux.sh should have exited with return value 0 if script ran already once for the specified directory path ${OUTDIR} as parameter"
	fi	
fi

#Delete and create pipes everytime as this can result in output data corruption
#These lines ensure that the build starts from scratch for every student
echo "Deleting pipe, aesd-build and default directory"
rm /tmp/guest.in /tmp/guest.out
sudo rm -rf "${cdir}/aesd-build"		
sudo rm -rf /tmp/ecen5013
