#! /bin/bash

set -e
set -x

# Prepare the image
pacman -Sy --noconfirm
pacman -S --noconfirm archlinux-keyring
pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm

pacman -S --noconfirm parted btrfs-progs file libnewt dosfstools jq util-linux zstd xz curl wget

# Create the frzr group
groupadd -g 379 frzr
usermod -a -G frzr $(whoami)

export FILENAME=image.img
export BUILD_DIR="/workdir/output"
export BUILD_IMG="$BUILD_DIR/$FILENAME"

mkdir -p "$BUILD_DIR"
dd if=/dev/zero of=$BUILD_IMG bs=1M count=8192

# Associate the image file with a loop device
losetup -fP "$BUILD_IMG"

# Find the loop device associated with the image file
MOUNTED_DEVICE=$(losetup -a | grep "$FILENAME" | cut -d ' ' -f 1 | sed 's/://')

export DISK="$MOUNTED_DEVICE"
export SWAP_GIB=0
bash /workdir/frzr bootstrap

# Display what's mounted
mount

export SKIP_UEFI_CHECK="yes"
export MOUNT_PATH="/tmp/frzr_root"
export EFI_MOUNT_PATH="/tmp/frzr_root/efi"
export FRZR_SKIP_CHECK="yes"
export SYSTEMD_RELAX_ESP_CHECKS=1
bash /workdir/frzr deploy chimeraos/chimeraos:45_1

# Umount the loopback device
losetup -d "$MOUNTED_DEVICE"

# Remove the file
rm -f $BUILD_IMG