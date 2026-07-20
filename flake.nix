{
  description = "config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11"; # Add this stable source
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    autovirt = {
      url = "github:Scrut1ny/AutoVirt";
      flake = false;
    };
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
      home-manager,
      chaotic,
      grub2-themes,
      nixpkgs-stable,
      nix-flatpak,
      autovirt,
      ...
    }:
    let
	system = "x86_64-linux";
  supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs { inherit system; config.allowUnfree = true; };
    in    
	{
      nixosModules = {
        default = self.nixosModules.barelyMetal;
        barelyMetal = import ./pkgs/modules {
          inherit self autovirt;
        };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          callPackage = pkgs.callPackage;
        in
        {
          default = callPackage ./pkgs/probe.nix { };
          probe = callPackage ./pkgs/probe.nix { };
          deploy = callPackage ./pkgs/libvirt-xml.nix { };

          qemu-patched = callPackage ./pkgs/qemu.nix {
            inherit autovirt;
            cpu = "amd";
          };
          qemu-patched-intel = callPackage ./pkgs/qemu.nix {
            inherit autovirt;
            cpu = "intel";
          };

          ovmf-patched = callPackage ./pkgs/ovmf.nix {
            inherit autovirt;
            cpu = "amd";
          };
          ovmf-patched-intel = callPackage ./pkgs/ovmf.nix {
            inherit autovirt;
            cpu = "intel";
          };

          smbios-spoofer = callPackage ./pkgs/smbios-spoofer.nix { inherit autovirt; };
          utils = callPackage ./pkgs/utils.nix { inherit autovirt; };
          guest-scripts = callPackage ./pkgs/guest-scripts.nix { inherit autovirt; };
        }
      );

      devShells = forAllSystems (system: {
        default =
          let
            pkgs = pkgsFor system;
          in
          pkgs.mkShell {
            packages = with pkgs; [
              qemu
              libvirt
              virt-manager
              pciutils
              dmidecode
            ];
          };
      }); 
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
specialArgs = {
  inherit inputs autovirt;
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
};        modules = [
          nixos-facter-modules.nixosModules.facter
          home-manager.nixosModules.home-manager
          chaotic.homeModules.default
          grub2-themes.nixosModules.default
	  nix-flatpak.nixosModules.nix-flatpak     
    self.nixosModules.default     
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
