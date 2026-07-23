{
  description = "config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixcord.url = "github:4evy/nixcord";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    AutoVirt = {
      url = "github:Scrut1ny/AutoVirt";
      flake = false;
    };
#    grub2-themes = {
#      url = "github:vinceliuice/grub2-themes";
#    };
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
      nix-flatpak,
      AutoVirt,
      lanzaboote,
      ...
    }:
    let
      system = "x86_64-linux";
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor =
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      nixosModules = {
        default = self.nixosModules.nixVirt;
        nixVirt = import ./pkgs/modules {
          inherit self AutoVirt;
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
            inherit AutoVirt;
          };
          ovmf-patched = callPackage ./pkgs/ovmf.nix {
            inherit AutoVirt;
            virt-firmware = pkgs.python3Packages.virt-firmware;
          };
          smbios-spoofer = callPackage ./pkgs/smbios-spoofer.nix { inherit AutoVirt; };
          utils = callPackage ./pkgs/utils.nix { inherit AutoVirt; };
          guest-scripts = callPackage ./pkgs/guest-scripts.nix { inherit AutoVirt; };
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
          inherit inputs AutoVirt;
        };
        modules = [
          nixos-facter-modules.nixosModules.facter
          home-manager.nixosModules.home-manager
          chaotic.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak
          self.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          ./modules/boot.nix
          ./hosts/default/configuration.nix
          
            ({pkgs, lib, ...}: {
            environment.systemPackages = [ pkgs.sbctl ];
            boot.loader.systemd-boot.enable = lib.mkForce false;
            boot.lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
            };
          }
          )
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            home-manager.useUserPackages = true;
            home-manager.users.lordofchaos = import ./hosts/default/home/home.nix;
          }
        ];
      };
    };
}

