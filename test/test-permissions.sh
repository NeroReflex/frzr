#! /bin/bash

set -e
set -x

# Prepare the image
pacman -Sy --noconfirm
pacman -S --noconfirm archlinux-keyring
pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm

pacman -S --noconfirm parted btrfs-progs file libnewt dosfstools jq util-linux zstd xz curl wget arch-install-scripts base-devel make git

# Create the frzr group
groupadd -g 379 frzr
usermod -a -G frzr $(whoami)
useradd tester
usermod -a -G frzr tester

cd /workdir && make install

# run frzr version from current user
frzr version

# run frzr version from another user
runuser -u tester -- frzr version

sudo rm /tmp/frzr.tracker

# run frzr version from tester user
runuser -u tester -- frzr version

# run frzr version from current user
frzr version