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
  virtualisation.libvirtd.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
}
