{
  lib,
  stdenv,
  AutoVirt,
}:

stdenv.mkDerivation {
  pname = "nixvirt-guest-scripts";
  version = "1.0.0";

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/nixvirt/guest-scripts/windows
    mkdir -p $out/share/nixvirt/acpi

    # Windows guest anti-detection scripts
    cp ${AutoVirt}/resources/scripts/Windows/EDID_OVERRIDE.ps1 $out/share/nixvirt/guest-scripts/windows/
    cp ${AutoVirt}/resources/scripts/Windows/qemu-cleanup.ps1 $out/share/nixvirt/guest-scripts/windows/

    # Bundled ACPI tables
    cp ${AutoVirt}/patches/QEMU/spoofed_devices.dsl $out/share/nixvirt/acpi/
    if [ -f ${AutoVirt}/patches/QEMU/spoofed_devices.aml ]; then
      cp ${AutoVirt}/patches/QEMU/spoofed_devices.aml $out/share/nixvirt/acpi/
    fi
  '';

  meta = {
    description = "nixvirt guest scripts and ACPI tables for anti-detection";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
