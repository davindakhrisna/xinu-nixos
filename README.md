# Xinu on NixOS

Build and experiment with Xinu on a NixOS host using one diskless QEMU/KVM backend. The host runs the compiler and libvirt supplies PXE DHCP, TFTP, and NAT. No Debian development VM or Minicom is required.

## Set up once

Enable libvirt on the host and give your account access to `qemu:///system` and KVM. A typical NixOS configuration includes:

```nix
virtualisation.libvirtd.enable = true;
users.users.YOUR_USERNAME.extraGroups = [ "libvirtd" ];
```

After applying the configuration and signing in again, clone the repository and enter its build environment:

```sh
git clone https://github.com/davindakhrisna/xinu-nixos.git
cd xinu-nixos
nix-shell
```

Build the kernel, prepare the TFTP directory, and define the network and backend:

```sh
make -C xinu-vbox/compile
install -d -m 755 /var/tmp/xinu-tftp
install -m 644 xinu-vbox/tftpboot/xinu.boot /var/tmp/xinu-tftp/xinu.boot
virsh -c qemu:///system net-define xinu_net.xml
virsh -c qemu:///system define backend.xml
virsh -c qemu:///system net-autostart xinu_net --disable
virsh -c qemu:///system autostart backend --disable
```

## Run and experiment

```sh
./run-xinu.sh
```

The script rebuilds Xinu, refreshes the boot image, starts its network if needed, starts or resets the backend, and opens the serial console. Wait for `xsh $`, then try `help`, `ps`, `memstat`, `uptime`, or `netinfo`. The backend obtains its reserved address `10.0.2.131/24` through DHCP; the host bridge is `10.0.2.1`.

Press **Ctrl+]** to detach from the console. To change your experiment, edit `xinu-vbox/system/main.c` or another source file, then run `./run-xinu.sh` again. Each launch resets an already running backend, discarding its current in-memory experiment.

**Xinu does not start automatically when the host boots.** Both backend and network autostart are disabled. Detaching from the console leaves Xinu running; stop it explicitly when finished:

```sh
virsh -c qemu:///system destroy backend
virsh -c qemu:///system net-destroy xinu_net
```

The backend has no disk. Its kernel and runtime state live in memory; your edited source remains on the host.

## Source and QEMU changes

`xinu-vbox/` comes from the [Purdue Xinu VirtualBox distribution](https://www.cs.purdue.edu/homes/comer/downloads/Xinu_Book_And_Code/VirtualBox/). The upstream [copyright notice](xinu-vbox/COPYRIGHT) is preserved.

The Ethernet driver uses the QEMU 82545EM's memory-mapped register BAR. Xinu's data and stack segment limits permit access to those PCI registers while its managed memory limit stays at 16 MiB. The build uses host GCC/binutils, excludes precompiled artifacts from Git, and tracks header dependencies so driver edits rebuild every affected object.

Validated with a build from source, PXE boot to the Xinu shell, DHCP address acquisition, and a successful ping to QEMU's gateway. External services and Internet connectivity depend on the host's network configuration.
