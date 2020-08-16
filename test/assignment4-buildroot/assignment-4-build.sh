#!/bin/bash
# 1st argument: absolute or relative path to the base directory
# Defaults to dirname `git rev-parse --absolute-git-dir` if not specified

source script-helpers

script_dir="$(pwd -P )"
testdir=$1
qemu_executable_path=/usr/bin	#Path where writer,finder,tester.sh are stored
ROOTFS_PATH=buildroot/output/target/${qemu_executable_path}		# add ${script_dir} before buildroot to make it an absolute path 

pushd ${testdir}
. ${script_dir}/buildroot-common-build.sh
rc=$?
# Validating if finder.sh and tester.sh exists, are sh scripts, have executable permissions.
# Bash is not available in buildroot.
# Building again if any changes are made.
if [ $rc -eq 0 ]; then
	echo "Checking if finder.sh and tester.sh are sh or bash scripts."

	if [ ! -e ${ROOTFS_PATH}/tester.sh ]; then
		add_validate_error "tester.sh does not exists in ${qemu_executable_path} inside qemu"
	else
		echo "tester.sh exists in ${qemu_executable_path} inside qemu"
		if [ ! -x ${ROOTFS_PATH/tester.sh} ]; then
			add_validate_error "tester.sh does not have executable permissions"
			echo "Setting executable permissions for tester.sh"
			chmod a+x ${ROOTFS_PATH}/tester.sh
		fi

		cat "${ROOTFS_PATH}/tester.sh" | grep "#!/bin/bash"
		rc=$?
		if [ $rc -eq 0 ]; then
			add_validate_error "tester.sh contains #!/bin/bash"
			echo "#!/bin/bash replaced by #!/bin/sh in tester.sh"
			sed -i 's/bash/sh/' "${ROOTFS_PATH}/tester.sh"
		else
			echo "tester.sh already consists of #!/bin/sh"
		fi
	fi

	
	if [ ! -e ${ROOTFS_PATH}/finder.sh ]; then
		add_validate_error "finder.sh does not exists in ${qemu_executable_path} inside qemu"
	else
		echo "finder.sh exists in ${qemu_executable_path} inside qemu"
		if [ ! -x ${ROOTFS_PATH/finder.sh} ]; then
			add_validate_error "finder.sh does not have executable permissions"
			echo "Setting executable permissions for finder.sh"
			chmod a+x ${ROOTFS_PATH}/finder.sh
		fi

		cat "${ROOTFS_PATH}/finder.sh" | grep "#!/bin/bash"
		rc=$?
		if [ $rc -eq 0 ]; then
			add_validate_error "finder.sh contains #!/bin/bash"
			echo "#!/bin/bash replaced by #!/bin/sh in finder.sh"
			sed -i 's/bash/sh/' "${ROOTFS_PATH}/finder.sh"
		else
			echo "finder.sh already consists of #!/bin/sh"
		fi
	fi
else
	add_validate_error "Build script failed with error $rc"
fi
# Use this to test validation errors are actually caught and handled properly
#add_validate_error "Testing validation error"
popd
