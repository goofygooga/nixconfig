{
  config,
  pkgs,
  lib,
  ...
}:
{
 boot.loader.grub = {
enable = true;
device = "nodev";
efiSupport = true;
configurationLimit = 5;
 }; 

#boot.kernelModules = [ "it87" "i2c-dev" ];
boot.extraModprobeConfig = ''
  options it87 force_id=0x8628
'';
hardware.fancontrol.enable = true;
programs.coolercontrol.enable = true;
hardware.fancontrol.config = ''
  # Your pwmconfig mappings go here
'';
services.hardware.openrgb.enable = true;
boot.loader.grub2-theme = {
    enable = true;
    theme = "whitesur";
    footer = true;
    customResolution = "1920x1080";  # Optional: Set a custom resolution
  };
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.kernelModules = [
    "vfio_virqfd"
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio"
    "xpad"
"it87" "i2c-dev"
  ];
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "nowatchdog"
    "quiet"
    "splash"
    "loglevel=3"
    "nvme_load=YES"
    "nvidia-drm.modeset=1"
    "nouveau.modeset=0"
    "transparent_hugepage=always"
    "tsc=reliable"
    "kvm.ignore_msrs=1"
    "kvm.report_ignored_msrs=0"
  ];
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.efi.canTouchEfiVariables = true;
}
