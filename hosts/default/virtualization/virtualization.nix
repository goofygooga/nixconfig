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
  virtualisation.docker = {
  enable = true;
  };
  # 2. Install Distrobox system-wide
  environment.systemPackages = with pkgs; [
    distrobox
  ];

  # 3. Add your user to the docker group (replace "yourusername")
  users.users.lordofchaos = {
    extraGroups = [ "docker" ];
  };
}
