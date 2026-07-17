{
  description = "config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11"; # Add this stable source
    barely-metal = {
      url = "github:goofygooga/BarelyMetal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
    };
silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
   };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-facter-modules,
      barely-metal,
      home-manager,
      chaotic,
      grub2-themes,
      nixpkgs-stable,
      ...
    }:
    let
	system = "x86_64-linux";
    in    
	{
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { pkgs-stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; }; inherit inputs; };
        modules = [
          barely-metal.nixosModules.default
          nixos-facter-modules.nixosModules.facter
          home-manager.nixosModules.home-manager
          chaotic.homeModules.default
          grub2-themes.nixosModules.default
          ./modules/boot.nix
          ./hosts/default/configuration.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lordofchaos = import ./hosts/default/home/home.nix;
          }

          (
            { pkgs, lib, ... }:
            {
            }
          )
        ];
      };
    };
}
