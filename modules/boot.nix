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
boot.loader.grub2-theme = {
    enable = true;
    theme = "whitesur";
    footer = true;
    customResolution = "1920x1080";  # Optional: Set a custom resolution
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.kernelModules = [
    "vfio_virqfd"
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio"
    "xpad"
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
    "mitigations=off"
    "transparent_hugepage=always"
  ];
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.efi.canTouchEfiVariables = true;
}
