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
  };
users.users.lordofchaos = { extraGroups = [ "openrazer"]; };
 hardware.openrazer.enable = true;
  programs.localsend.enable = true;
  users.defaultUserShell = pkgs.zsh; # Example: zsh, fish, nushell
  environment.shells = [ pkgs.zsh ];
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    alsa-utils
    sbctl
    google-chrome
    #heroic
    efibootmgr
    usbutils
    qemu
    dnsmasq
    bibata-cursors
    wget
    nerd-fonts.jetbrains-mono
    wine
    winetricks
    alacritty
    timeshift
    ddcutil
    python3
    go
    ninja
    gnumake
    gcc
    vscode-fhs
    vscodium-fhs
    rbenv
    ruby
    piper
    javaPackages.compiler.openjdk25
    psmisc
    kmod
    gnome-keyring
  libsecret  
polychromatic
openrazer-daemon
quickshell
noctalia-qs
nautilus
];
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

      theme = "gentoo";
    };

  };
}
