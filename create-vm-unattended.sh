#!/bin/sh

if [ -z "$1" ] ;
then
 echo Specify a virtual-machine name.
 exit 1
fi

sudo qemu-img create -f qcow2  /var/lib/libvirt/images/test.qcow2 10G


sudo virt-install \
--name test \
--ram 4096 \
--disk path=/var/lib/libvirt/images/test.qcow2 \
--vcpus 2 \
--os-type linux \
--os-variant ubuntu16.04 \
--network bridge:br0,model=virtio \
--graphics none \
--console pty,target_type=serial \
--location=/var/lib/libvirt/isos/ubuntu-16.04-netboot-amd64-unattended.iso \
--extra-args 'console=ttyS0,115200n8 serial'


exit 0 

# virt-install 
--name CentOS7 
--ram 1024 
--disk path=/home/josepy/Libvirt/images/centos-server.qcow2 
--vcpus 1 
--os-type linux 
--os-variant ubuntu16.04 
--graphics none 
--console pty,target_type=serial 
--location /home/josepy/Kvm images/CentOS-7-x86_64-Minimal-1503-01.iso 
--extra-args 'console=ttyS0,115200n8 serial'


sudo virt-install \
--connect qemu:///system \
--ram 1024 \
--os-variant ubuntu16.04 \
--ram 2048 \
--os-type=linux \
--os-variant=rhel5 \
--disk path=/home/trapapa/playground/linux-unattended-installation/ubuntu-16.04-amd64-2048-10G.qcow2,device=disk,bus=virtio,format=qcow2 \
--vcpus=2 \
--vnc \
--noautoconsole \
--import