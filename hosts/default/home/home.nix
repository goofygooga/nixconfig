{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home.username = "lordofchaos";
  home.homeDirectory = "/home/lordofchaos";
  home.stateVersion = "26.11";
  
	imports = [ ./discord.nix ];


  home.packages = with pkgs; [
    hollywood
    btop
    nixfmt
    prismlauncher
    git-credential-manager
    obsidian
    git
    vlc
    tree
    nerd-fonts.jetbrains-mono
tmux
    #heroic
#    gamescope
#    gamemode
  ];
programs.vscode = {
  enable = true;
  extensions = with pkgs.vscode-extensions; [
    dracula-theme.theme-dracula
    anthropic.claude-code
    yzhang.markdown-all-in-one
  ];
};
programs.neovim.enable = true;
programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 12;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold Italic";
        };
      };
      window.opacity = 0.95;
    };
  };
programs.neovim = {
viAlias = true;
  vimAlias = true;};
  programs.neovim.plugins = [
  pkgs.vimPlugins.LazyVim ];
  programs.git = {
    enable = true;
    userName = "Scorcher";
    userEmail = "harrypotterr1233@gmail.com";

    settings = {
      credential.helper = "manager";
      credential.credentialStore = "cache";
    };
  };
  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo = {
        type = "small";
        padding = {
          top = 1;
        };
      };

      display = {
        separator = " ";
      };

      modules = [
        {
          type = "custom";
          key = "╭───────────╮";
        }

        {
          type = "title";
          key = "│ {#31} user    {#keys}│";
          format = "{user-name}";
        }

        {
          type = "title";
          key = "│ {#32}󰇅 hname   {#keys}│";
          format = "{host-name}";
        }

        {
          type = "uptime";
          key = "│ {#33}󰅐 uptime  {#keys}│";
        }

        {
          type = "os";
          key = "│ {#34}{icon} distro  {#keys}│";
        }

        {
          type = "kernel";
          key = "│ {#35} kernel  {#keys}│";
        }

        {
          type = "de";
          key = "│ {#36}󰇄 desktop {#keys}│";
        }

        {
          type = "terminal";
          key = "│ {#31} term    {#keys}│";
        }

        {
          type = "shell";
          key = "│ {#32} shell   {#keys}│";
        }

        {
          type = "cpu";
          key = "│ {#33}󰍛 cpu     {#keys}│";
          showPeCoreCount = true;
        }

        {
          type = "disk";
          key = "│ {#34}󰉉 disk    {#keys}│";
          folders = "/";
        }

        {
          type = "memory";
          key = "│ {#35} memory  {#keys}│";
        }

        {
          type = "localip";
          key = "│ {#36}󰩟 network {#keys}│";
          format = "{ipv4} ({ifname})";
        }

        {
          type = "custom";
          key = "├───────────┤";
        }

        {
          type = "colors";
          key = "│ {#39} colors  {#keys}│";
          symbol = "circle";
        }

        {
          type = "custom";
          key = "╰───────────╯";
        }
      ];
    };
  };

  home.file = {
    # ".screenrc".source = ./dotfiles/screenrc;
    # ".config/niri/config.kdl".source = ./niri/config.kdl;
  };
  programs.home-manager.enable = true;
}
