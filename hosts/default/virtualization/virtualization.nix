{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./autovirt.nix
    ./passthrough.nix
  ];
  programs.virt-manager.enable = true;
  hardware.i2c.enable = true;
  virtualisation.libvirtd.enable = true;
  hardware.nvidia-container-toolkit.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
}
