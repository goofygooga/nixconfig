{ pkgs, inputs, ... }:
{
  # install package
  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    # ... maybe other stuff
    nwg-look
    papirus-icon-theme # Reliable, complete fallback icon set
    
    # Packages for Option 2 (Qt)
    qt6Packages.qt6ct
    libsForQt5.qt5ct # Recommended fallback for older Qt5 apps
  ];
nix.settings = {
  extra-substituters = [ "https://noctalia.cachix.org" ];
  extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
};
environment.variables = {
    # Choose ONE of the lines below:
#    QT_QPA_PLATFORMTHEME = "gtk3"; # Use this for Option 1 (GTK)
    # QT_QPA_PLATFORMTHEME = "qt6ct"; # Use this for Option 2 (Qt)
 #  QS_ICON_THEME="Papirus";
  };
}
