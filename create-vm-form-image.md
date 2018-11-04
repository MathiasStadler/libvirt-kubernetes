
# from images


## 1st try


```bash
sudo qemu-system-x86_64 \
  -drive /var/lib/libvirt/images/archlinux20170101.qcow2,format=qcow2,size=10G \
  -m 2048 -enable-kvm -M q35 \
  -cpu host -smp 4,sockets=1,cores=4,threads=1 \
  -bios /usr/share/qemu/bios.bin -boot menu=on \
  -cdrom /var/lib/libvirt/archlinux-2017.01.01-dual.iso
```


## sources

```txt
#arch qemu
https://wiki.archlinux.org/index.php/QEMU

```