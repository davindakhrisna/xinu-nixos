# Xinu on QEMU/KVM

Download the disk and start both VMs:

```sh
gh release download v1.0.0 -p 'xinu-disk.zst.part-*'
cat xinu-disk.zst.part-* | zstd -d -o xinu-development-system.qcow2
sudo mv xinu-development-system.qcow2 /var/lib/libvirt/images/
virsh net-define xinu_net.xml && virsh net-autostart xinu_net
virsh define development-system.xml && virsh define backend.xml
virsh start development-system && virsh start backend
```
