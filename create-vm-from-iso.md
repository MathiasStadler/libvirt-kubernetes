# create-vm-from-iso

## old variante 

```bash
qemu-system-x86_64 \
-boot d \
-cdrom /var/lib/libvirt/isos/ubuntu_16.4_mini.iso  \
-m 4096 \
-drive file=/home/trapapa/playground/linux-unattended-installation/mydisk.img,index=0,media=disk,format=raw
```

## sources

```txt
https://github.com/hartwork/grub2-theme-preview/issues/7
https://manpages.debian.org/stretch/qemu-system-x86/qemu-system-x86_64.1.en.html
https://unix.stackexchange.com/questions/404436/create-a-virtual-machine-from-the-cli-kvm

```

## new version

```bash

CREATE_VM_FROM_ISO="create-vm-from-iso.sh"
cat <<EOF >$CREATE_VM_FROM_ISO
if [ -z "\$1" ] ;
then
 echo Specify a virtual-machine name.
 exit 1
fi

if [ -z "\$2" ] ;
then
 echo Specify a iso file with full path.
 exit 1
fi

sudo virt-install \
--name \$1 \
--ram=2048 \
--vcpus=2 \
--os-type linux \
--os-variant ubuntu16.04 \
--disk path=/var/lib/libvirt/images/\$1.img,size=30 \
--cdrom \$2 \
--network bridge:br0,model=virtio \
--graphics none \
--boot cdrom,hd,menu=on \
--graphics vnc,listen=0.0.0.0,password=Qwerty1234

EOF

chmod +x $CREATE_VM_FROM_ISO

```

## connect with vnc

```bash
ssh trapapa@192.168.178.62 -L 5900:127.0.0.1:5900

# start vnc viewer and select port 127.0.0.1:5900

```

## found open vnc port

```bash
# sudo virsh dumpxml <vm-name> |grep gra
sudo virsh dumpxml test-1 |grep gra
```

## found listen ports e.g. open vnc ports

```bash
# from here
# https://www.binarytides.com/linux-ss-command/

# list all listen ports
ss -ltn

```


## sources

```txt
https://unix.stackexchange.com/questions/404436/create-a-virtual-machine-from-the-cli-kvm

# vnc libvirt
https://blog.scottlowe.org/2013/09/10/adjusting-vnc-console-access-via-libvirt-xml/
# vnc jump over other server
https://blog.scottlowe.org/2013/08/21/accessing-vnc-consoles-of-kvm-guests-via-ssh/

```








virt-install \
-n vmname \
-r 2048 \
--os-type=linux \
--os-variant=ubuntu \
--disk /kvm/images/disk/vmname_boot.img,device=disk,bus=virtio,size=40,sparse=true,format=raw \
-w bridge=br0,model=virtio \
--vnc \
--noautoconsole \
-c /var/lib/libvirt/isos/ubuntu_16.4_mini.iso

