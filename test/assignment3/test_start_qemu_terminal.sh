# !/bin/bash

set -e

OUTDIR=/tmp/ecen5013

if [ $# -lt 1 ]
then
	echo -e "\nUSING DEFAULT DIRECTORY ${OUTDIR}\n"
else
	OUTDIR=$1
fi

if [ -d "$OUTDIR" ]
then
	echo -e "\nDIRECTORY ALREADY EXISTS\n"
else
	exit 1
fi

echo -e "\nUSING ${OUTDIR} DIRECTORY for qemu test run\n"

cd "$OUTDIR"

#Booting the kernel
echo -e "\nStarting qemu\n"
set -o xtrace
QEMU_AUDIO_DRV=none qemu-system-arm ${AESD_QEMU_EXTRA_ARGS} -m 256M -nographic -M versatilepb -kernel zImage -append "console=ttyAMA0 rdinit=/home/assignment-3-test-init.sh" -dtb versatile-pb.dtb -initrd initramfs_testing.cpio.gz
set +o xtrace
