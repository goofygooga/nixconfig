{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.silentSDDM.nixosModules.default
  ];
  programs.silentSDDM = {
    enable = true;
    theme = "default";
  };
  networking.networkmanager.enable = true;
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = false;
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true; 
  programs.hyprland.withUWSM = true;
 services.xserver.videoDrivers = [ "nvidia" ];
#  boot.kernelPackages = pkgs.recurseIntoAttrs (
#    pkgs.linuxKernel.packagesFor (
#      pkgs.linuxKernel.kernels.linux_7_1.override {
#        kernelPatches = [
#          {
#            name = "Those Who Know";
#            patch = ../pkgs/extpatches/yo.patch;
#          }
#        ];
#      }
#    )
#  );
boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaPersistenced = true;
    open = true;
    nvidiaSettings = true;
 package = config.boot.kernelPackages.nvidiaPackages.latest;  
};
}
