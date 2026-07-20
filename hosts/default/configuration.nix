# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop.nix
    ../../modules/pkgs.nix
    ./virtualization/virtualization.nix
  ];
  boot.zswap.enable = true;
  zramSwap.enable = false;
  
  services.scx.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Never Debounce]
    MatchUdevType=mouse
    ModelBouncingKeys=1
  '';
  networking.hostName = "logan"; # Define your hostname.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  nix.settings.trusted-substituters = [ "https://attic.xuyh0120.win/lantian" ];

  time.timeZone = "America/Toronto";

  i18n.defaultLocale = "en_CA.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
services.input-remapper = {
  enable = true;
  package = (import inputs.nixpkgs-stable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  }).input-remapper;
};

hardware.uinput.enable = true;
services.input-remapper.enableUdevRules = true;

  # Enable CUPS to print documents.
  services.printing.enable = false;
  hardware.alsa.enablePersistence = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

  };
  services.power-profiles-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;
  # users.users.lordofchaos.group = "lordofchaos";
  #users.groups.lordofchaos = {};

  users.users.lordofchaos = {
    isNormalUser = true;
    #    group = "lordofchaos";
    description = "Scott Tran";
    extraGroups = [
      "networkmanager"
      "kvm"
      "input"
      "qemu"
      "plugdev"
      "audio"
      "video"
      "render"
      "wheel"
      "uinput"
    ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.dolphin
      kdePackages.ark
    ];
  };
services.udisks2.enable = true;
  # Install firefox.
  programs.firefox.enable = true;
  programs.firefox.package = pkgs.firefox-bin;
  programs.gamescope.enable = true;
programs.gamemode.enable = true;
  # Allow unfree packages
  #  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

 services.udev.extraRules = ''
  # HIDRAW access for browser configuration (VIA / WebHID)
  SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idVendor}=="3151", ATTRS{idProduct}=="502d", MODE="0666", TAG+="uaccess"

  # USB subsystem access
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="3151", ATTRS{idProduct}=="502d", MODE="0666", TAG+="uaccess"
'';


  services.openssh.enable = true;
  networking.firewall.enable = true;
  system.stateVersion = "26.05";

}
