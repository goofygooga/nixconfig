{ config, pkgs, inputs, ... }:
{
  services.flatpak = {
    enable = true;
  };
  programs.steam = {
    enable = true; # Master switch, already covered in installation
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
    extraPackages = with pkgs; [ bibata-cursors ];
  };
  users.users.lordofchaos = {
    extraGroups = [ "openrazer" ];
  };
  hardware.openrazer.enable = true;
  services.flatpak.packages = [
    "org.vinegarhq.Sober"
    "com.spotify.Client"
    "com.dec05eba.gpu_screen_recorder"
    "com.surfshark.Surfshark"
  ];
  programs.localsend.enable = true;
  users.defaultUserShell = pkgs.zsh; # Example: zsh, fish, nushell
  environment.shells = [ pkgs.zsh ];
  environment.systemPackages = with pkgs; [
    psst
    alsa-utils
    google-chrome
    heroic
    (heroic.override {
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
    efibootmgr
    usbutils
    qemu
    dnsmasq
    bibata-cursors
    wget
    protonup-qt
    nerd-fonts.jetbrains-mono
    ddcutil
    pfetch    
    qbittorrent
    psmisc
    kmod
    libsecret
    polychromatic
    openrazer-daemon
    nvibrant
    kitty
    input-remapper
    xwayland-satellite
    linux-wallpaperengine
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    kdePackages.kio
kdePackages.plasma-integration
kdePackages.kservice
  ];
  programs.gamemode.enable = true;

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

      theme = "af-magic";
    };

  };
}
