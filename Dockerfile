# docker build -t linux-live .
# docker run -ti -v `pwd`/out:/tmp linux-live ./build-disk.sh
# kvm -cdrom bin/ipxe.iso   -m 4096 -net nic -net user -serial stdio  -nographic -monitor null
# https://wiki.debian.org/InitramfsDebug
FROM ubuntu:18.04
RUN echo deb http://us.archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse >> /etc/apt/sources.list
ARG DEBIAN_FRONTEND=noninteractive
ENV KERNEL 5.4.0-37-generic
RUN mkdir -p /etc/initramfs-tools/ /var/run
COPY initramfs.conf /etc/initramfs-tools/
RUN apt-get update && apt-get install --no-install-recommends -y \
  -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
  linux-image-$KERNEL squashfs-tools zip xz-utils systemd-sysv ca-certificates \
  vim-nox cpio sudo iproute2  network-manager netplan pciutils live-boot \
  live-boot-initramfs-tools syslinux-common isolinux genisoimage openssh-server
WORKDIR /root
RUN sed -i 's/ALL$/NOPASSWD:ALL/' /etc/sudoers && \
 echo "[Network]\nDHCP=yes" >> /etc/systemd/network/00-dhcp.network && \
 echo "\n[keyfile]\nunmanaged-devices=*,except:type:ethernet\n" >> /etc/NetworkManager/NetworkManager.conf && \
  useradd -m hello -s /bin/bash -G sudo && \
  echo "hello:world" | chpasswd
ENV NFS_BOOT_ARGS netboot=nfs nfsroot=192.168.1.226:/nfs/
COPY ./build-disk.sh isolinux.cfg ./
