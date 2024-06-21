# frzr

frzr is a deployment and automatic update mechanism for operating systems.

It deploys pre-built systems that have been generated using btrfs send to snapshot a rootfs image.

## Features
Despite frzr being the deployment software for chimeraos it has been designed to handle every linux distribution,
even embedded ones or the more traditional ones.

Each distibution can either be immutable or read/write, immutable distros can choose how they want to achieve the goal
and implement a distro-specific way of unlocking the filesystem.

frzr aims at:
- ensuring safe and atomic updates that never interrupt the user
- distributing a known tested and working copy of a system
- allows easier transitioning among different operating systems and versions
- allows installing one kernel that can be shared among all installed systems

## How
Updated system images are downloaded at boot time and deployed to an entirely separate subvolume so as not to interfere with the currently running system. Upon next boot, the newly installed system is started and the old one is deleted, completely seamlessly and invisibly.

Actions to be performed when installing the system, unlocking it (if required) and uninstalling it are distro-specific and are provided
via scripts that frzr runs when performing the requested action.

## More
To ease system management and system debuggability frzr can be used to keep a primary distro on the main btrfs subvolume and
manage deployments in a completely separate way so that your beloved archlinux install will remain usable whenever you want to.

Also frzr ships with utilities that are meant to regenerate bootloader entries whenever a kernel gets installed or uninstalled.