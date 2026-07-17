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
virtualisation.docker.enableNvidia = true;
hardware.nvidia-container-toolkit.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
   virtualisation = {
    # Enable Docker

    # Enable Podman
    podman = {
      enable = true;
      # Create a `docker` alias for podman (handy if you want podman to mimic docker)
      dockerCompat = true;
      # Required for containers to look up each other's IP addresses via DNS
      defaultNetwork.settings.dns_enabled = true;
    };
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
