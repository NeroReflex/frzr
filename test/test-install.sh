#! /bin/bash

set -e
set -x

FILENAME=image.img
BUILD_IMG="/output/$FILENAME"

dd if=/dev/zero of=$BUILD_IMG bs=1M count=4096

# Associate the image file with a loop device
losetup -fP $FILENAME

# Find the loop device associated with the image file
MOUNTED_DEVICE=$(losetup -a | grep "$FILENAME" | cut -d ' ' -f 1 | sed 's/://')

bash /workdir/frzr bootstrap $MOUNTED_DEVICE