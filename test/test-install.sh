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

FILENAME=image.img
BUILD_DIR="/workdir/output"
BUILD_IMG="$BUILD_DIR/$FILENAME"

mkdir -p "$BUILD_DIR"
dd if=/dev/zero of=$BUILD_IMG bs=1M count=4096

# Associate the image file with a loop device
losetup -fP "$BUILD_IMG"

# Find the loop device associated with the image file
MOUNTED_DEVICE=$(losetup -a | grep "$FILENAME" | cut -d ' ' -f 1 | sed 's/://')

DISK="$MOUNTED_DEVICE" SWAP_GIB=0 bash /workdir/frzr bootstrap
SKIP_UEFI_CHECK="yes" MOUNT_PATH="/tmp/frzr_root" FRZR_SKIP_CHECK="yes" bash /workdir/frzr deploy chimeraos/chimeraos:45_1

# Umount the loopback device
losetup -d "$MOUNTED_DEVICE"

# Remove the file
rm -f $BUILD_IMG