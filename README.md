# libvirt-kubernetes

## source

```txt
# install manjaro
https://computingforgeeks.com/complete-installation-of-kvmqemu-and-virt-manager-on-arch-linux-and-manjaro/

https://blog.alexellis.io/kvm-kubernetes-primer/
https://blog.alexellis.io/your-instant-kubernetes-cluster/


# network calico
https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#tabs-pod-install-7


# kickstart file 
http://manpages.ubuntu.com/manpages/cosmic/man1/virt-install.1.html

```

## TODO

- install libvirt
- create bridge br0 for libvirt vm . This is necessary for reach the vm from network
- install three and more ubuntu 16.04.04 libvirt vm
- install kubernetes
- init kubernetes master
- join kubernetes worker-node
- enable virsh console for Ubuntu 16.4.4

## env
    - Lenovo T430 i5 RAM 16GB SSD 500GB found by my reseller
    - Linux manjaro 4.19.0-3-MANJARO #1 SMP PREEMPT Sat Oct 27 22:40:22 UTC 2018 x86_64 GNU/Linux

## install libvirt

```bash
# update manjaro
sudo pacman-mirrors --fasttrack 5 && sudo pacman -Syyu
# install libvirt
sudo pacman -S qemu virt-manager virt-viewer dnsmasq iptables vde2 bridge-utils openbsd-netcat
sudo pacman -S ebtables
sudo pacman -S iptables

# enable libvirt service
sudo systemctl enable libvirtd.service
# start services
systemctl start libvirtd.service
# set option for kernel model
echo “options kvm-intel nested=1″ | sudo tee /etc/modprobe.d/kvm-intel.conf
# reboot host and check
cat /sys/module/kvm_intel/parameters/nested
# output should: Y fine :-)
```

## create bridge br0

```bash
# set network config
sudo cat <<EOF >/etc/sysctl.d/99-sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
net.ipv4.ip_forward = 1
EOF

# activate w/o reboot
sudo sysctl --system

# set bridge
# my phy network interface is  enp0s25
sudo cp /etc/netctl/examples/bridge /etc/netctl/bridge
sudo vim /etc/netctl/bridge

# set/edit  your real phy network interface in the file /etc/netctl/bridge
#
# BindsToInterfaces=(enp0s25)
#
# save file

# start bridge
sudo netctl start bridge

# check with command
ip show addr
# ip addr has change

# make our bridge start on boot
sudo netctl enable bridge

```

## install three and more ubuntu 16.04.04 libvirt vm

```bash



## kubernetes start

```bash

cat <<EOF >create-vm.sh
#!/bin/sh
if [ -z "\$1" ] ;
then
 echo Specify a virtual-machine name.
 exit 1
fi

sudo virt-install \
--name \$1 \
--ram 4096 \
--disk path=/var/lib/libvirt/images/$1.img,size=30 \
--vcpus 2 \
--os-type linux \
--os-variant ubuntu16.04 \
--network bridge:br0,model=virtio \
--graphics none \
--console pty,target_type=serial \
--location 'http://gb.archive.ubuntu.com/ubuntu/dists/xenial/main/installer-amd64/' \
--extra-args 'console=ttyS0,115200n8 serial'
EOF

chown +x create-vm.sh

./create-vm.sh k8s-master
./create-vm.sh k8s-1
./create-vm.sh k8s-2

# follow the install instruction

```

## install kubernetes

```bash
# execute the block on each master and node
sudo apt update && sudo apt install curl

# instll k8s on ubuntu
# from here
# https://kubernetes.io/docs/setup/independent/install-kubeadm/#installing-runtime

apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# swap off
sudo swapoff -a
# comment the swap line out of the /etc/fstab
sudo sed -i '/swap/s/^/#/g' /etc/fstab


# for network IP Virtual Server
sudo  apt install ipvsadm

```

## init kubernetes master

```bash

# on k9s-master node
sudo kubeadm init --pod-network-cidr=192.168.178.0/24

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# deploy a pod network to the cluster
# from here
# https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#tabs-pod-install-7

kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

# on all worker node k8s-1 , k8s-2 ...
# this came from output
sudo kubeadm join 192.168.178.63:6443 --token zmvzdd.26e0cioeuur5sm5d --discovery-token-ca-cert-hash sha256:fc8d658a3367430a4fa9d9a3c9d2855150433734c5734945386b1dad6fb5b9da

# on k8s-master
kubectl get nodes
# you should see the 1st worker node k8s-node-1

# NAME         STATUS     ROLES    AGE    VERSION
# k8s-master   NotReady   master   103m   v1.12.2
# k8s-node1    NotReady   <none>   24s    v1.12.2

```

## enable virsh console for Ubuntu 16.4.4

| SECURITY VIOLATION Not used in production environment.

- change each libvirt config e.g. k8s-master

```bash

> virsh edit k8s-master

# force with vi editor
EDITOR=/usr/bin/vi virsh edit k8s-master

```

- to


```xml

<serial type='pty'>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
</serial>
<console type='pty'>
      <target type='serial' port='0'/>
</console>

```

- and change the /etc/default/grub config if the vm running


``` bash

# GRUB_CMDLINE_LINUX=""
GRUB_CMDLINE_LINUX='console=ttyS0,115200'

```

- now can you login via console


```bash

virsh console k8s-master

# press enter if see no output

```

- check you are login via ttyS0 used command w

```bash

> w
15:32:18 up  2:08,  2 users,  load average: 0.27, 0.34, 0.23
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
ubuntu   ttyS0                     15:26    2.00s  0.10s  0.00s w
ubuntu   pts/0    192.168.178.23   13:23    2:08m  0.04s  0.04s -bash

```

- leave the virsh console press

```txt

[STRG] + ]
[STRG] + 5

```