{ config, lib, inputs, ... }:
{
  	imports = [ inputs.nixos-facter-modules.nixosModules.facter ];
 facter.reportPath = ./facter.json;
  barelyMetal = {
    enable = true;

    # Pass your hardware probe data
    probeData = builtins.fromJSON (builtins.readFile ./probe.json);

    # Users to add to kvm, libvirtd, input groups
    users = [ "lordofchaos" ];

    # Replace the OVMF boot logo (saved by barely-metal-probe)
    spoofing.bootLogo = ./boot-logo.bmp;

    vm = {
      memory = 8192; # MiB
      cores = 8;
      threads = 2;
      audioBackend = "none";
      diskSize = "500G";
      # Laptop spoofing (fake ACPI battery + embedded controller/fan/power button)
      # useFakeBattery = true;
      # useSpoofedDevices = true;

      # Windows ISO for initial install
      # isoPath = /path/to/Win11.iso;

      # evdev input passthrough
      # evdevInputs = [
      #   "/dev/input/by-id/usb-Logitech_G502-event-mouse"
      #   "/dev/input/by-id/usb-Corsair_K70-event-kbd"
      # ];

      # Hyper-V passthrough mode (some anti-cheats prefer this over hidden KVM)
      enableHyperVPassthrough = false;
    };

    # GPU passthrough (optional)
    # vfio = {
    #   enable = true;
    #   pciIds = [ "10de:2484" "10de:228b" ];
    # };

    # Looking Glass shared memory display (optional)
    # lookingGlass = {
    #   enable = true;
    #   user = "myuser";
    #   shmSize = 64;
    # };
  };
}
