{
  description = "Scott On Dat Sheet Bro";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    barely-metal = {
      url = "github:goofygooga/BarelyMetal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-cachyos-kernel,
      barely-metal,
      nixos-facter-modules,
      lanzaboote,
      home-manager,
chaotic,
grub2-themes,
      ...
    }:
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          lanzaboote.nixosModules.lanzaboote
          barely-metal.nixosModules.default
          nixos-facter-modules.nixosModules.facter
          home-manager.nixosModules.home-manager
chaotic.homeModules.default
grub2-themes.nixosModules.default
          ./modules/boot.nix
          ./hosts/default/configuration.nix
./modules/noctalia.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lordofchaos = import ./home/home.nix;
          }

          (
            { pkgs, lib, ... }:
            {
              nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ];
              environment.systemPackages = [
                pkgs.hello
              ];
              boot.loader.systemd-boot.enable = false;
            }
          )
        ];
      };
    };
}
