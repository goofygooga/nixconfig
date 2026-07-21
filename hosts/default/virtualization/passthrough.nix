{ config, pkgs, lib, ... }:
let
  gpuHook = pkgs.writeShellScript "libvirt-gpu-hook" ''
    #!/usr/bin/env bash
    set -x

    VM="$1"
    OP="$2"
    PHASE="$3"

    TARGET_VM="BarelyMetal"

    if [ "$VM" = "$TARGET_VM" ] && [ "$OP" = "prepare" ] && [ "$PHASE" = "begin" ]; then
      echo "Preparing GPU for passthrough"




      ${pkgs.systemd}/bin/systemctl isolate multi-user.target
      ${pkgs.systemd}/bin/systemctl stop nvidia-persistenced.service || true
      ${pkgs.systemd}/bin/systemctl stop bluetooth
      sleep 2
      ${pkgs.psmisc}/bin/fuser -k /dev/nvidia* || true

      echo 0 > /sys/class/vtconsole/vtcon0/bind || true
      echo 0 > /sys/class/vtconsole/vtcon1/bind || true

      echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind || true
      
      sleep 2
	${pkgs.kmod}/bin/modprobe -r nvidia_drm
${pkgs.kmod}/bin/modprobe -r nvidia_uvm
${pkgs.kmod}/bin/modprobe -r nvidia_modeset
${pkgs.kmod}/bin/modprobe -r nvidia
	
      ${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_00_14_0
      ${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_01_00_0
      ${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_01_00_1
      ${pkgs.kmod}/bin/modprobe vfio-pci
    fi


    if [ "$VM" = "$TARGET_VM" ] && [ "$OP" = "release" ] && [ "$PHASE" = "end" ]; then
      echo "Reattaching GPU to host"

      ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_01_00_1
      ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_01_00_0
      ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_00_14_0
      ${pkgs.kmod}/bin/modprobe -r vfio-pci
	sleep 2
      ${pkgs.kmod}/bin/modprobe nvidia
      ${pkgs.kmod}/bin/modprobe nvidia_modeset
      ${pkgs.kmod}/bin/modprobe nvidia_uvm
      ${pkgs.kmod}/bin/modprobe nvidia_drm

      echo 1 > /sys/class/vtconsole/vtcon0/bind || true
      echo 1 > /sys/class/vtconsole/vtcon1/bind || true

      nvidia-xconfig --query-gpu-info > /dev/null 2>&1 || true

      echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind || true

      ${pkgs.systemd}/bin/systemctl start nvidia-persistenced.service || true
      ${pkgs.systemd}/bin/systemctl start bluetooth
      ${pkgs.systemd}/bin/systemctl isolate graphical.target
    fi
    '';
    hugepagesHook = pkgs.writeShellScript "hugepagesHook" ''
    #!/usr/bin/env bash
    set -x
    VM="$1"
    OP="$2"
    PHASE="$3"

    # change to your VM name
    TARGET_VM="BarelyMetal"
    if [ "$VM" = "$TARGET_VM" ] && [ "$OP" = "prepare" ] && [ "$PHASE" = "begin" ]; then
        echo "Hugepages hook incoming!"
        
        sync && echo 3 | tee /proc/sys/vm/drop_caches
        sysctl vm.compact_memory=1
        echo 1 | tee /proc/sys/vm/compact_memory
	sysctl vm.nr_hugepages=6912
      fi
    if [ "$VM" = "$TARGET_VM" ] && [ "$OP" = "release" ] && [ "$PHASE" = "end" ]; then
        echo "Releasing hugepages back to host"
        sysctl vm.nr_hugepages=0
      fi
  '';
in
{
virtualisation.libvirtd.hooks.qemu = {
  "gpu-passthrough" = gpuHook; 
  "hugepages" = hugepagesHook;
  };
environment.systemPackages = [ pkgs.kmod ];
}
