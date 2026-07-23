{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.nixos-facter-modules.nixosModules.facter ];
  facter.reportPath = ./facter.json;
  nixvirt = {
    enable = true;

    probeData = builtins.fromJSON (builtins.readFile ./probe.json);

    users = [ "lordofchaos" ];

    spoofing.bootLogo = ./boot-logo.bmp;

    vm = {
      memory = 4096; # MiB
      cores = 8;
      threads = 2;
      audioBackend = "none";
      diskSize = "500G";
      enableHyperVPassthrough = true;
    };
  };
}
