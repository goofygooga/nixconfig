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
   virtualisation.docker = {
  enable = true;
  # Customize Docker daemon settings using the daemon.settings option
  daemon.settings = {
    dns = [ "1.1.1.1" "8.8.8.8" ];
    log-driver = "journald";
    registry-mirrors = [ "https://mirror.gcr.io" ];
    storage-driver = "overlay2";
  };
  # Use the rootless mode - run Docker daemon as non-root user
  rootless = {
    enable = true;
    setSocketVariable = true;
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
