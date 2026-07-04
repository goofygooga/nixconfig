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
    alacritty
    timeshift
    ddcutil
    python3
    vscode
    (vscode-with-extensions.override {
    vscodeExtensions = with vscode-extensions; [
      bbenoist.nix
      ms-python.python
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "remote-ssh-edit";
        publisher = "ms-vscode-remote";
        version = "0.47.2";
        sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      }
    ];
  })
    piper
    reaper
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
