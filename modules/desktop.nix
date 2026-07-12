{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [inputs.silentSDDM.nixosModules.default];
    programs.silentSDDM = {
        enable = true;
        theme = "default";
        # settings = { ... }; see example in module
    };
  networking.networkmanager.enable = true;
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.windowManager.dwm.enable = true;
  services.xserver.windowManager.dwm.package = pkgs.dwm.overrideAttrs (oldAttrs: rec {
    patches = [
      # for local patch files, replace with relative path to patch file
      # for external patches
      (pkgs.fetchpatch {
        # replace with actual URL
        url = "https://dwm.suckless.org/patches/actualfullscreen/dwm-actualfullscreen-20211013-cb3f58a.diff";
        hash = "sha256-vsTuudJCy7Zo1wdwpI/nY7Zu1txXx90QoDfJLmfDUH8=";
      })
      (pkgs.fetchpatch {
    url = "https://dwm.suckless.org/patches/xfce4-panel/dwm-xfce4-panel-20220306-d39e2f3.diff";
    hash = "sha256-Z+B2qfGTdNY7RD7lbZM6SU9zyTxgdhl42o1mnhdqjqI=";
    }
    )
    ];
  });
  #programs.ssh.askPassword = lib.mkDefault "...";
  #programs.ssh.askPassword = lib.mkForce "${pkgs.ksshaskpass}/bin/ksshaskpass";
  #  programs.seahorse.enable = false;
  #  services.displayManager.gdm.enable = true;
  #  services.desktopManager.gnome.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelPackages = pkgs.linuxPackages;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;   # Latest beta driver
  hardware.nvidia = {

    # Modesetting is required.
     modesetting.enable = true;
    nvidiaPersistenced = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    #powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
     open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
  };
}
