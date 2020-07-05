#!/bin/bash

cd `dirname $0`
source script-helpers
source assignment-timeout
source assignment-3-checks

scriptsdir=`pwd`

pushd ../../../

# For run within the docker container, to ensure we have acces to crosstool-ng tools
export PATH="/home/autotest-admin/x-tools/arm-unknown-linux-gnueabi/bin:${PATH}"

OUTDIR=${1}
manual_linux_success_flag=0		#This flag signifies atleast one test case for manual_linux.sh has passed


#Function to check cross compile makefile functionality and execuatble creation
makefile_check

# #Replace #!/bin/bash by #!/bin/sh in tester.sh and finder.sh if found
# ##WARNING: Students might prefix sh to a file containing #!/bin/bash to make it work
#bash_to_sh "tester.sh"
#bash_to_sh "finder.sh"


#Running manual_linux.sh with already existing correct directory path as parameter
mkdir "${OUTDIR}"
echo "Running manual_linux.sh with parameter"
./manual_linux.sh "${OUTDIR}"
rc=$?
if [ $rc -ne 0 ]; then
	add_validate_error "manual_linux.sh should have exited with return value 0 if correct existing directory path was specified as a parameter"
else
	manual_linux_success_flag=1		
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
fi
popd
