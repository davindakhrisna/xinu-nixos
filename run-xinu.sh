#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

root=$(cd -- "$(dirname -- "$0")" && pwd)
virsh=(virsh -c qemu:///system)
make -C "$root/xinu-vbox/compile" CC=gcc LD=ld
install -d -m 755 /var/tmp/xinu-tftp
install -m 644 "$root/xinu-vbox/tftpboot/xinu.boot" /var/tmp/xinu-tftp/xinu.boot
if ! "${virsh[@]}" net-info xinu_net | grep -q 'Active:.*yes'; then
  "${virsh[@]}" net-start xinu_net
fi
if "${virsh[@]}" domstate backend | grep -q running; then
  "${virsh[@]}" reset backend
else
  "${virsh[@]}" start backend
fi
exec "${virsh[@]}" console backend
