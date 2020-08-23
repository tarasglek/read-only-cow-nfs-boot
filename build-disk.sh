#!/bin/sh
set -x -e
export OUTFILE=/tmp/live/rootfs.squashfs
export OPTS="-comp xz -b 1024K -always-use-fragments -keep-as-directory -no-recovery"
rm -fr /tmp/live
mkdir -p /tmp/live/
mksquashfs /bin /etc /home /lib /lib64 /opt /root /sbin /srv /usr /var /dev $OUTFILE $OPTS
rm -fR /tmp/empty
mkdir /tmp/empty
(cd /tmp/empty && mkdir sys proc && mksquashfs sys proc $OUTFILE $OPTS)
#make iso and drop kernel/initrd into place
ISOLINUX=/tmp/iso/isolinux
mkdir -p $ISOLINUX
cp /boot/vmlinuz-* $ISOLINUX/vmlinuz
cp /boot/initrd.img-* $ISOLINUX/initrd
cp isolinux.cfg $ISOLINUX/
cp /usr/lib/ISOLINUX/isolinux.bin /usr/lib/syslinux/modules/bios/ldlinux.c32 $ISOLINUX/
(cd /tmp/iso && mkisofs -o /tmp/boot.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table .)
mv $ISOLINUX/initrd $ISOLINUX/vmlinuz /tmp
rm -fr /tmp/iso /tmp/empty