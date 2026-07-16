{ config, pkgs, ... }:
{
  services.flatpak = {
    enable = true;
  };
  programs.steam = {
    enable = true; # Master switch, already covered in installation
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting

    # Other general flags if available can be set here.
  extraCompatPackages = [ pkgs.proton-cachyos_x86_64_v3 ];
  };
  users.users.lordofchaos = {
    extraGroups = [ "openrazer" ];
  };
  hardware.openrazer.enable = true;
  
  programs.localsend.enable = true;
  users.defaultUserShell = pkgs.zsh; # Example: zsh, fish, nushell
  environment.shells = [ pkgs.zsh ];
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    #alsa-utils
#    sbctl
    heroic
    (heroic.override {
  extraPkgs = pkgs': with pkgs'; [
    gamescope
    gamemode
  ];
})
 #   efibootmgr
  #  usbutils
    qemu
    dnsmasq
    bibata-cursors
    wget
    protonup-qt
    nerd-fonts.jetbrains-mono
   # timeshift
    ddcutil
    #python3
    #piper
    #reaper
    #javaPackages.compiler.openjdk25
    psmisc
    kmod
    gnome-keyring
    libsecret
    polychromatic
    openrazer-daemon
    quickshell
    noctalia-qs
    nautilus
    xwayland-satellite
    nvibrant
kdePackages.polkit-kde-agent-1

config.services.input-remapper.package
#proton-cachyos_x86_64_v3
  ];

  # Force the package to build using a working, stable Python 3.12 environment
 programs.gamemode.enable = true;
  programs.niri.enable = true;

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    histSize = 10000;

    shellAliases = {
      ll = "ls -lah";
      rebuild = "sudo nixos-rebuild switch";
    };

    setOptions = [
      "AUTO_CD"
      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
    ];

    ohMyZsh = {
      enable = true;

      plugins = [
        "git"
        "dirhistory"
        "history"
        "sudo"
      ];

      theme = "robbyrussell";
    };

  };
}
