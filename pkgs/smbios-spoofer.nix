{
  lib,
  python3,
  AutoVirt,
  makeWrapper,
}:

python3.pkgs.buildPythonApplication {
  pname = "nixvirt-smbios-spoofer";
  version = "1.0.0";
  format = "other";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/nixvirt
    cp ${AutoVirt}/resources/scripts/Linux/SMBIOS.py $out/share/nixvirt/smbios_spoofer_cli.py
    makeWrapper ${python3}/bin/python3 $out/bin/nixvirt-smbios-spoofer \
      --add-flags "$out/share/nixvirt/smbios_spoofer_cli.py"
  '';

  meta = {
    description = "Generate spoofed SMBIOS tables for QEMU anti-detection";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "nixvirt-smbios-spoofer";
  };
}
