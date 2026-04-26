{
  description = "Scott On Dat Sheet Bro";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    barely-metal = {
      url = "github:Dreaming-Codes/BarelyMetal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
          ./modules/boot.nix
          ./hosts/default/configuration.nix

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
              boot.loader.systemd-boot.enable = lib.mkForce false;
              boot.lanzaboote = {
                enable = true;
                pkiBundle = "/var/lib/sbctl";
              };
            }
          )
        ];
      };
    };
}
