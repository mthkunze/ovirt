#!/bin/bash

# Specify settings here.
VM_GUEST_DOMAIN="new-guest"
BASE_GUEST_DOMAIN="ubuntu-16.04-docker-image"
BASE_GUEST_DISK="/vms/base-images/ubuntu-16.04.qcow2"
VM_GUEST_FOLDER="/vms/$VM_GUEST_DOMAIN"
VM_GUEST_DISK="`echo $VM_GUEST_FOLDER`/`echo $VM_GUEST_DOMAIN`.qcow2"
VM_GUEST_XML_PATH="`echo $VM_GUEST_FOLDER`/`echo $VM_GUEST_DOMAIN`.xml"

# Create a directory for anything related 
# to our guest such as snapshots
mkdir -p $VM_GUEST_FOLDER

# Create a qcow2 disk file for our new guest.
sudo qemu-img create \
  -f qcow2 \
  -b $BASE_GUEST_DISK \
  $VM_GUEST_DISK

# Generate a new xml file for the guest.
# This takes care of changing the MAC address for us.
sudo virt-clone \
  --original $BASE_GUEST_DOMAIN \
  --name $VM_GUEST_DOMAIN \
  --file=$VM_GUEST_DISK \
  --preserve-data \
  --print-xml > $VM_GUEST_XML_PATH

# Use the xml file to define the new guest
sudo virsh define $VM_GUEST_XML_PATH
sudo rm $VM_GUEST_XML_PATH
