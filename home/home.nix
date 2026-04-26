{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should manage.

  home.username = "lordofchaos";
  home.homeDirectory = "/home/lordofchaos";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "26.05"; # Set this to the version you are using
  # The home.packages option allows you to install Nix packages into your environment.
  home.packages = [
    pkgs.htop
    pkgs.fastfetch
    pkgs.thunar
    pkgs.hollywood
    pkgs.btop
    pkgs.nixfmt
    pkgs.prismlauncher
    pkgs.git-credential-manager
    pkgs.git
  ];
  programs.git = {
  enable = true;
  settings = {
    credential.helper = "secretservice";
  };
};
  # Home Manager is adept at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # ".screenrc".source = dotfiles/screenrc;
  };

  # You can also manage environment variables.
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
