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
    ./autovirt/autovirt.nix
    ../../modules/virtualization.nix
    ./autovirt/passthrough.nix
    inputs.vfio-stealth.nixosModules.default
  ];
  nixpkgs.overlays = [ inputs.vfio-stealth.overlays.default ];
  myModules.vfio.stealth.enable = true;
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
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  #  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  services.openssh.enable = true;
  networking.firewall.enable = false;
  system.stateVersion = "26.05";

}
