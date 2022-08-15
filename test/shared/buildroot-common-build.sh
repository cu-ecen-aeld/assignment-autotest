#!/bin/bash
# Common buildroot based build script
# Run this script using `. ./buildroot-common-build.sh` after sourcing the assignment helper script
# from this directory or one with necessary functions:
#   add_validate_error
#   validate_buildroot_config
#   before_script
# Before sourcing this script, ensure you have changed directory to the root of the buildroot
# build directory (which includes build.sh script)

# Ensure we use download cache by specifying on the commandline
export BR2_DL_DIR=~/.dl
mkdir -p ${BR2_DL_DIR}

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

if [ $rc -ne 0 ]; then
	add_validate_error "Build script failed with error $rc"
fi
