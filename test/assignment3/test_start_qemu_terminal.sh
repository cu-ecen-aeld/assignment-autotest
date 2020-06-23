# !/bin/sh

set -e

OUTDIR=/tmp/ecen5013

if [ $# -lt 1 ]
then
	echo -e "\nUSING DEFAULT DIRECTORY ${OUTDIR}\n"
else
	OUTDIR=$1
	echo -e "\nUSING ${OUTDIR} DIRECTORY\n"
fi

if [ -d "$OUTDIR" ]
then
	echo -e "\nDIRECTORY ALREADY EXISTS\n"
else
	exit 1
fi


cd "$OUTDIR"

#Booting the kernel
echo -e "\nBOOTING THE KERNEL\n"
echo QEMU_AUDIO_DRV=none qemu-system-arm -serial pipe:/tmp/guest -m 256M -nographic -M versatilepb -kernel zImage -append "console=ttyAMA0 rdinit=/home/assignment-3-test-init.sh" -dtb versatile-pb.dtb -initrd initramfs_testing.cpio.gz
QEMU_AUDIO_DRV=none qemu-system-arm ${AESD_QEMU_EXTRA_ARGS} -serial pipe:/tmp/guest -m 256M -nographic -M versatilepb -kernel zImage -append "console=ttyAMA0 rdinit=/home/assignment-3-test-init.sh" -dtb versatile-pb.dtb -initrd initramfs_testing.cpio.gz
