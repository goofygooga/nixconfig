{ config, lib, inputs, ... }:
{
  	imports = [ inputs.nixos-facter-modules.nixosModules.facter ];
 facter.reportPath = ./facter.json;
  barelyMetal = {
    enable = true;

  
    probeData = builtins.fromJSON (builtins.readFile ./probe.json);

  
    users = [ "lordofchaos" ];

  
    spoofing.bootLogo = ./boot-logo.bmp;

    vm = {
      memory = 8192; # MiB
      cores = 8;
      threads = 2;
      audioBackend = "none";
      diskSize = "500G";
  
      isoPath = /home/lordofchaos/Downloads/Win11_25H2_English_x64_v2.iso;
    
      enableHyperVPassthrough = false;
    };
  };
}
