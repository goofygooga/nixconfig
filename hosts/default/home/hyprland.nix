{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home.packages = with pkgs; [
    rofi
    grimblast
    nwg-look
    papirus-icon-theme
    alacritty
  ];
  programs.kitty.enable = true;
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.extraConfig = ''
        # Move windows with SUPER + left click
        bindm = SUPER, mouse:272, movewindow

        # Resize windows with SUPER + right click
        bindm = SUPER, mouse:273, resizewindow

  '';

  wayland.windowManager.hyprland = {
    package = null;
    portalPackage = null;
  };
  wayland.windowManager.hyprland.configType = "hyprlang";
  wayland.windowManager.hyprland.systemd.variables = [ "--all" ];
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 20;
  };
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    monitor = [
      "DP-1, 1920x1080@164.92, 0x0, 1"
    ];
    input = {
      sensitivity = -0.18;
      accel_profile = "flat";
    };
    "exec-once" = [
      "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
      "noctalia-shell"
      "xwayland-satellite"
      "hyprctl setcursor Bibata-Modern-Ice 20"
      "nvibrant 0 512"
    ];
    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 2;
    };
    decoration = {
      rounding = 20;
      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)"; # Note: Colors must be wrapped in quotation marks
      };
      blur = {
        enabled = true;
        size = 3;
        passes = 2;
        vibrancy = 0.1696;
      };
    };
    animations = {
      enabled = false;
    };
    bind = [
      "$mod, B, exec, firefox"
      ", Print, exec, grimblast copy area"
      "$mod, Return, exec, alacritty"
      "$mod, D, exec, rofi -show drun"
      "$mod, E, exec, dolphin"
      ", XF86AudioPlay, exec, noctalia-shell ipc call media playPause"
      ", XF86AudioNext, exec, noctalia-shell ipc call media next"
      ", XF86AudioPrev, exec, noctalia-shell ipc call media previous"
      ", XF86AudioRaiseVolume, exec, noctalia-shell ipc call volume increase"
      ", XF86AudioLowerVolume, exec, noctalia-shell ipc call volume decrease"
      ", XF86AudioMute, exec, noctalia-shell ipc call volume muteOutput"
      "$mod, Q, killactive"
      "$mod, F, fullscreen, 1"
      "$mod SHIFT, F, fullscreen, 1"
      "CTRL ALT, Delete, exec, hyprctl dispatch exit"
      "$mod, space, togglefloating"
    ]
    ++ (
      # workspaces
      # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
      builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = i + 1;
          in
          [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
          ]
        ) 9
      )
    );
  };
}
