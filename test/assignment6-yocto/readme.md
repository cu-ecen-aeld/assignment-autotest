# Validation Checks for Assignment 6.

## CHECKS ADDED:
- Yocto has been added as a submodule. If not add yocto as a submodule and checkout branch warrior.
- openssh package inclusion in "meta-aesd/recipes-aesd-assignments/images/core-image-aesd.bb". If not add openssh package.
- ssh link is used in the aesd-assignments_git.bb file. If not replace https link by ssh.
- aesd-assignments package has been added in "meta-aesd/recipes-aesd-assignments/images/core-image-aesd.bb". If not add the package.
- build.sh has executable permissions. If not set executable permissions.
- runqemu.sh has been added and has executable permissions. If not create and set executable permissions.
- Deploying build.sh.
- aesdsocket-start-stop exists in /etc/init.d and aesdsocket exists in /usr/bin.
- If aesdsocket is not found in /usr/bin, add a validation error and do not execute runqemu.sh, adding a validation error for the same.
- Check if aesdsocket-start-stop is sh script. If not change it to sh script and build again. 
- Makefile consists of Wall and Werror flags in makefile/Makefile.
- Makefile can build an executable on host machine using make or make all.
- Valgrind check for memeory leaks on host machine after running sockettest.sh and killing it to cover all kinds of memory leaks. 
- Execute runqemu.sh and run sockettest.sh to check if the executable passes test cases inside qemu.
- aesdsocket executable runs as a daemon. If not run it as daemon to carry out further tests.
- Signal handlers function for SIGINT and SIGTERM.
- /var/tmp/aesdsocketdata or /var/tmp/aesdsocketdata.txt file is deleted on exiting from signal handler. If not delete the file.


## CHECKS REMAINING:
- Count of Global Variables
- Change assignment_timeout from 90m to 60m
- What if runqemu hangs? and does not proceed. The test script would be stuck for 60 minutes.
 
