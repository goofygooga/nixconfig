{ config, pkgs, lib, ... }:
let
  gpuHook = pkgs.writeShellScript "libvirt-gpu-hook" ''
     #!/usr/bin/env bash
    set -x

    VM="$1"
    OP="$2"
    PHASE="$3"

    # change to your VM name
    TARGET_VM="BarelyMetal"

    if [ "$VM" = "$TARGET_VM" ] && [ "$OP" = "prepare" ] && [ "$PHASE" = "begin" ]; then
      echo "Preparing GPU for passthrough"



      ${pkgs.systemd}/bin/systemctl stop display-manager.service
      ${pkgs.systemd}/bin/systemctl isolate multi-user.target

      ${pkgs.systemd}/bin/loginctl terminate-seat seat0 || true

      ${pkgs.systemd}/bin/systemctl stop nvidia-persistenced.service || true
      ${pkgs.systemd}/bin/systemctl stop nvidia-powerd.service 2>/dev/null || true
      ${pkgs.systemd}/bin/systemctl stop bluetooth

      ${pkgs.psmisc}/bin/fuser -k /dev/nvidia* || true

      echo 0 > /sys/class/vtconsole/vtcon0/bind || true
      echo 0 > /sys/class/vtconsole/vtcon1/bind || true

      echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind || true
      for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo performance > "$gov"
done
      sleep 2

      ${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_01_00_0
      ${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_01_00_1
      ${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_00_1f_0
${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_00_1f_5
${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_00_1f_4
      ${pkgs.kmod}/bin/modprobe vfio-pci
    fi


    if [ "$VM" = "$TARGET_VM" ] && [ "$OP" = "release" ] && [ "$PHASE" = "end" ]; then
      echo "Reattaching GPU to host"

      ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_01_00_1
      ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_01_00_0
${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_00_1f_0
${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_00_1f_5
${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_00_1f_4


      ${pkgs.kmod}/bin/modprobe -r vfio-pci
      for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo schedutil > "$gov"
done
      ${pkgs.kmod}/bin/modprobe nvidia
      ${pkgs.kmod}/bin/modprobe nvidia_modeset
      ${pkgs.kmod}/bin/modprobe nvidia_uvm
      ${pkgs.kmod}/bin/modprobe nvidia_drm

      echo 1 > /sys/class/vtconsole/vtcon0/bind || true
      echo 1 > /sys/class/vtconsole/vtcon1/bind || true

      nvidia-xconfig --query-gpu-info > /dev/null 2>&1 || true

      echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind || true

      ${pkgs.systemd}/bin/systemctl start nvidia-persistenced.service || true
      ${pkgs.systemd}/bin/systemctl start nvidia-powerd.service 2>/dev/null || true
      ${pkgs.systemd}/bin/systemctl start bluetooth

      ${pkgs.systemd}/bin/systemctl start display-manager.service
    fi
    '';
in
{
virtualisation.libvirtd.hooks.qemu = {"gpu-passthrough" = gpuHook; };
environment.systemPackages = [ pkgs.kmod ];
}
