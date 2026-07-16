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
#    ./virtualization/virtualization.nix

  ];
  swapDevices = [
  {
    device = "/var/lib/swapfile";
    size = 8 * 1024; # Size in mebibytes (16 GiB)
  }
];
  zramSwap.enable = false;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc
 stdenv.cc.cc

    # C/C++ runtime
    glibc
    gcc-unwrapped.lib

    # Common compression
    zlib
    xz
    zstd

    # SSL
    openssl

    # Terminal/UI
    ncurses

    # C++ ABI
    libgcc
xorg.libX11
  xorg.libXext
  xorg.libXrandr
  xorg.libXcursor
  xorg.libXi
  xorg.libXrender
  xorg.libXfixes
  xorg.libxcb
  wayland
  libGL
  vulkan-loader
  ];
  services.scx.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
   xdg.portal = {
    enable = true;
    #xdgOpenUsePortal = true;
    config = {
      common = {
        default = [
          "gnome"
        ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

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
environment.variables = {
  QT_QPA_PLATFORMTHEME = "gtk3";
#  QS_ICON_THEME="Papirus-Dark";
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

  services.openssh.enable = true;
  networking.firewall.enable = true;
  system.stateVersion = "26.05";

}
