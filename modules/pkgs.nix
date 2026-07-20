{ config, pkgs, ... }:
{
  services.flatpak = {
    enable = true;
  };
  programs.steam = {
    enable = true; # Master switch, already covered in installation
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
    extraPackages =  with pkgs; [ bibata-cursors  ];
    # Other general flags if available can be set here.
  extraCompatPackages = [ pkgs.proton-cachyos_x86_64_v3 ];
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
	"org.waywallen.waywallen"
];  
  programs.localsend.enable = true;
  users.defaultUserShell = pkgs.zsh; # Example: zsh, fish, nushell
  environment.shells = [ pkgs.zsh ];
  environment.systemPackages = with pkgs; [
psst
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    #alsa-utils
google-chrome
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
qbittorrent
    psmisc
    kmod
    libsecret
    polychromatic
    openrazer-daemon
    nvibrant

config.services.input-remapper.package
  ];

  # Force the package to build using a working, stable Python 3.12 environment
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
