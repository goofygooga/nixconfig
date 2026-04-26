{
  config,
  pkgs,
  lib,
  ...
}:
{

  programs.virt-manager.enable = true;
  hardware.i2c.enable = true;
  virtualisation.libvirtd.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

}
