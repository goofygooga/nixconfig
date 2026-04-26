{
  config,
  pkgs,
  lib,
  ...
}:
{
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
  ];
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.efi.canTouchEfiVariables = true;
}
