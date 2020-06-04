#!/bin/bash
#
# ./prep-image IMAGE
#
#	IMAGE is the base raspian image
#
# Makes the following changes to a stock image
# - enables ssh
# - adds local root public ssh key (if readable) to image's root ssh authorized_keys
# - locks the password of the pi user

SSH_PUB_KEY=/root/.ssh/id_rsa.pub

function patch {
	# $1 - name of partition device (not the disk device)
	# $2 - patching function to call

	tmpdir=$(mktemp -d)
	mount $1 $tmpdir
	pushd $tmpdir > /dev/null
	$2
	popd > /dev/null
	umount $tmpdir
	rm -rf $tmpdir
}

function setup_boot {
	echo Enabling SSH
	touch ssh
}

function setup_root {
	if [ ! -d root/.ssh ]; then
		mkdir root/.ssh
	fi
	if [ -r $SSH_PUB_KEY ]; then
		echo Adding root public key to authorized_keys
		cat $SSH_PUB_KEY > root/.ssh/authorized_keys
		chmod 600 root/.ssh/authorized_keys
	fi

	echo Locking "pi" user account
	tmp=$(mktemp)
	cat etc/shadow | awk '/^pi:/ { split($0,t,":"); printf t[1]":*:"t[3]":"t[4]":"t[5]":"t[6]":"t[7]":"t[8]":"t[9]"\n"; next } {print}' > $tmp
	cat $tmp > etc/shadow
	rm -f $tmp
}

if [ $# -eq 0 ]; then
	echo "Usage: $0 IMAGE"
	exit -1
fi

losetup -fP $1
device=$(losetup -l | grep 2020-05-27-raspios-buster-lite-armhf.img | cut -d " " -f1)

patch ${device}p1 setup_boot
patch ${device}p2 setup_root

losetup -d $device
