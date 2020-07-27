#!/bin/bash
# 1st argument: absolute or relative path to the base directory
# Defaults to dirname `git rev-parse --absolute-git-dir` if not specified

source script-helpers
source assignment-timeout

script_dir="$(pwd -P )"
testdir=$1
qemu_executable_path=/bin	#Path where writer,finder,tester.sh are stored
ROOTFS_PATH=buildroot/output/target/${qemu_executable_path}		# add ${script_dir} before buildroot to make it an absolute path 
build_again=1			#1 indicates false

# Ensure we use download cache by specifying on the commandline
export BR2_DL_DIR=~/.dl
mkdir -p ${BR2_DL_DIR}
echo "Test directory is ${testdir}"
pushd ${testdir}

# Remove config if it exists, to clear any previous partial runs
rm -rf buildroot/.config

# Validating if aesd-assignments.mk has ssh link
grep "^AESD_ASSIGNMENTS_SITE[[:space:]]*=[[:space:]]*https" base_external/package/aesd-assignments/aesd-assignments.mk
rc=$?
if [ $rc -eq 0 ]; then
	add_validate_error "Using https instead of ssh URL in aesd-assignments.mk, will not build automated"
	echo "Replacing https link by ssh link manually in aesd-assignments.mk"
	sed -i 's/^AESD_ASSIGNMENTS_SITE[[:space:]]*=[[:space:]]*https:\/\/github.com\//AESD_ASSIGNMENTS_SITE = git@github.com:/g' base_external/package/aesd-assignments/aesd-assignments.mk
fi

# Validating if clean.sh exists and has executable permissions
if [ ! -e clean.sh ]; then
	add_validate_error "clean.sh does not exists"
	echo "Creating clean.sh and setting executable permissions"
	echo '#!/bin/bash' > clean.sh
	echo "make -C buildroot distclean" >> clean.sh
	chmod a+x clean.sh
else
	if [ ! -x clean.sh ]; then
		add_validate_error "clean.sh is not executable"
		echo "Setting executable permission for clean.sh"
		chmod a+x clean.sh
	fi
fi

# don't run clean.sh, since it doesn't work before build
# Validating if build.sh has executable permissions
if [ ! -x build.sh ]; then
	add_validate_error "build.sh is not executable"
	echo "Setting executable permission for build.sh"
	chmod a+x build.sh
fi

# Validating check for runquemu.sh as per the error in assignment document
if [ ! -e runqemu.sh ]; then
	if [ -e runquemu.sh ]; then
		echo "Moving runquemu.sh to runqemu.sh due to problem with assignment document"
		mv runquemu.sh runqemu.sh
	fi
fi

# Validating if runqemu.sh has executable permissions
if [ ! -x runqemu.sh ]; then
	add_validate_error "runqemu.sh is not executable"
	echo "Setting executable permissions for runqemu.sh"
	chmod a+x runqemu.sh
fi

# Validating correct buildroot configuration
validate_buildroot_config

# Setup keys
before_script

echo "Running build.sh for the first time"
bash build.sh
rc=$?
if [ $rc -eq 0 ]; then
	#Inserting a time delay of 5s
	sleep 5s

	# Build twice since the default build.sh script didn't build after setting up the defconfig
	echo "Running build.sh for the second time as user:"
	echo `whoami`
	bash build.sh
	rc=$?
    echo "Build returned $rc"
fi

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
			build_again=0
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
			build_again=0
		else
			echo "finder.sh already consists of #!/bin/sh"
		fi
	fi


	if [ $build_again -eq 0 ]; then
		echo "Running build.sh again due to modifications in tester.sh/finder.sh script"
		bash build.sh
        rc=$?
		if [ $rc -ne 0 ]; then
	        add_validate_error "Build script failed with error $rc after tester and finder script modifications"
        fi
	fi
else
	add_validate_error "Build script failed with error $rc"
fi
# Use this to test validation errors are actually caught and handled properly
#add_validate_error "Testing validation error"
popd
