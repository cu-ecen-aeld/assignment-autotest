#!/bin/sh


. ./script-helpers
. ./assignment-timeout

read_qemu "This architecture does not have kernel memory protection" >/dev/null 2>&1
#Prints obtained between these read_qemu functions would be validation check prints inside qemu
read_qemu "Inside QEMU: Exiting with"
exit 0
