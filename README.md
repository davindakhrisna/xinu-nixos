# Xinu on QEMU/KVM

Requires `xinu-development-system.qcow2` in `/var/lib/libvirt/images/` (not included).

```sh
virsh net-define xinu_net.xml && virsh net-autostart xinu_net
virsh define development-system.xml && virsh define backend.xml
virsh start development-system && virsh start backend
```
