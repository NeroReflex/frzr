#! /bin/bash

set -e
set -x

# Prepare the image
pacman -Sy --noconfirm
pacman -S --noconfirm archlinux-keyring
pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm

pacman -S --noconfirm parted btrfs-progs file libnewt dosfstools jq util-linux zstd xz curl wget arch-install-scripts

# Create the frzr group
groupadd -g 379 frzr
usermod -a -G frzr $(whoami)

export FILENAME=removal_image.img
export BUILD_DIR="/workdir/output"
export BUILD_IMG="$BUILD_DIR/$FILENAME"

mkdir -p "$BUILD_DIR"
dd if=/dev/zero of=$BUILD_IMG bs=1M count=16384

# Associate the image file with a loop device
losetup -fP "$BUILD_IMG"

# Find the loop device associated with the image file
MOUNTED_DEVICE=$(losetup -a | grep "$FILENAME" | cut -d ' ' -f 1 | sed 's/://')

cd /workdir && make install

export DISK="$MOUNTED_DEVICE"
export SWAP_GIB=0
frzr bootstrap

export SHOW_UI="0"
export SKIP_UEFI_CHECK="yes"
export MOUNT_PATH="/tmp/frzr_root"
export EFI_MOUNT_PATH="/tmp/frzr_root/efi"
export SYSTEMD_RELAX_ESP_CHECKS=1

# deploy chimeraos-43_6978095
frzr deploy chimeraos/chimeraos:43

if [ ! -d "$MOUNT_PATH/deployments/chimeraos-43_6978095" ]; then
	exit 1
fi

# deploy chimeraos-44_c3670dd
frzr deploy chimeraos/chimeraos:44

if [ ! -d "$MOUNT_PATH/deployments/chimeraos-43_6978095" ] || [ ! -d "$MOUNT_PATH/deployments/chimeraos-44_c3670dd" ]; then
	exit 1
fi

ls -lah "$MOUNT_PATH/deployments"

# deploy chimeraos-45_1e44050
frzr deploy chimeraos/chimeraos:45

if [ -d "$MOUNT_PATH/deployments/chimeraos-43_6978095" ] || [ ! -d "$MOUNT_PATH/deployments/chimeraos-44_c3670dd" ] || [ ! -d "$MOUNT_PATH/deployments/chimeraos-45_1e44050" ]; then
	exit 1
fi

ls -lah "$MOUNT_PATH/deployments"

# deploy chimeraos-45-1_9a95912
frzr deploy chimeraos/chimeraos:45-1

if [ -d "$MOUNT_PATH/deployments/chimeraos-44_c3670dd" ] || [ ! -d "$MOUNT_PATH/deployments/chimeraos-45_1e44050" ] || [ ! -d "$MOUNT_PATH/deployments/chimeraos-45-1_9a95912" ]; then
	exit 1
fi

# Umount the loopback device
losetup -d "$MOUNTED_DEVICE"

# Remove the file
rm -f $BUILD_IMG

