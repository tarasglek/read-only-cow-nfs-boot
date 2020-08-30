#!/bin/sh
set -x -e
export ISOLINUX=/tmp/iso/isolinux
export LIVEDIR=$ISOLINUX/../live
export OUTFILE=$LIVEDIR/rootfs.squashfs
export OPTS="-comp xz -b 1024K -always-use-fragments -keep-as-directory -no-recovery"
rm -fR /tmp/*
mkdir -p $ISOLINUX
mkdir -p $LIVEDIR
mksquashfs /bin /etc /home /lib /lib64 /opt /root /sbin /srv /usr /var /dev $OUTFILE $OPTS
# empty thing is to create sys,proc which squashfs can't copy cos they have special files in them
mkdir /tmp/empty
(cd /tmp/empty && mkdir sys proc && mksquashfs sys proc $OUTFILE $OPTS)
#make iso and drop kernel/initrd into place
export GENERATE_ISO="(cd /tmp/iso && mkisofs -o /tmp/boot.iso -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table .)"
# generate FULL cdrom image
cp /boot/vmlinuz-* $ISOLINUX/vmlinuz
cp /boot/initrd.img-* $ISOLINUX/initrd
cp /usr/lib/ISOLINUX/isolinux.bin /usr/lib/syslinux/modules/bios/ldlinux.c32 $ISOLINUX/
cp isolinux.cfg $ISOLINUX/
sed "s|NFS_BOOT_ARGS||" -i $ISOLINUX/isolinux.cfg
echo $GENERATE_ISO |sh

#generate network-boot image
mv /tmp/boot.iso /tmp/full.iso
mv $LIVEDIR /tmp/live
cp isolinux.cfg $ISOLINUX/
sed "s|NFS_BOOT_ARGS|$NFS_BOOT_ARGS|" -i $ISOLINUX/isolinux.cfg
echo $GENERATE_ISO | sh
mv /tmp/boot.iso /tmp/network-root.iso

#cleanup
mv $ISOLINUX/initrd $ISOLINUX/vmlinuz /tmp
rm -fr /tmp/iso /tmp/empty

chown -R $USER_GROUP /tmp/