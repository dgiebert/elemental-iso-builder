#!/bin/bash -x
# Generating image from ISO from container image

iso="output/tmp/elemental-teal.arm64.iso"
res="output/elemental-teal.rpi.iso"

[ -f "${iso}" ] || exit 1

rm "${res}"
echo "Mounting the generated ISO image"
mkdir iso rootfs mount
mount -o loop "${iso}" iso
mount -o loop iso/rootfs.squashfs rootfs

squash_size=$(du -m ${iso} | cut -f1) # Size of the rootfs.squashfs in MB
img_size=$((squash_size + 150))       # Size of rootfs.squashfs + boot partition in MB

dd if=/dev/zero of="${res}" bs=$((1 * 1024 * 1024)) count="${img_size}" # Create the resulting iso

losetup /dev/loop42 "${res}" # Create a loopback device for the iso

echo "Creating the a custom boot partition"
parted --script -- /dev/loop42 mklabel msdos                                               # Set the type to msdos
parted --script -- /dev/loop42 mkpart primary fat32 2048s 135MB set 1 boot on set 1 lba on # Create a primary partition for boot / EFI
parted --script -- /dev/loop42 mkpart primary ext3 135MB "${img_size}"MB                   # Creating the a custom root partition
mkfs -t vfat -n RPI_BOOT /dev/loop42p1                                                     # Create the FAT32 partition to boot off
mkfs -t ext3 -L COS_LIVE /dev/loop42p2                                                     # Create the EXT3 partition to store the rootfs

echo "Copy custom boot content"
mount /dev/loop42p1 mount
cp -a iso/EFI mount
cp -a iso/boot mount
cp -a rootfs/boot/vc/* mount
umount mount

mount /dev/loop42p2 mount
cp iso/rootfs.squashfs mount

cp livecd-cloud-config.yaml mount/

echo "Unmounting"
losetup -d /dev/loop42
umount rootfs mount iso
rmdir rootfs mount iso
