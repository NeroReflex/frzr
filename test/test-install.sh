#! /bin/bash

set -e
set -x

FILENAME=image.img
BUILD_DIR="/workdir/output"
BUILD_IMG="$BUILD_DIR/$FILENAME"

mkdir -p "$BUILD_DIR"
dd if=/dev/zero of=$BUILD_IMG bs=1M count=4096

# Associate the image file with a loop device
losetup -fP "$BUILD_IMG"

# Find the loop device associated with the image file
MOUNTED_DEVICE=$(losetup -a | grep "$FILENAME" | cut -d ' ' -f 1 | sed 's/://')

DISK="$MOUNTED_DEVICE" bash /workdir/frzr bootstrap