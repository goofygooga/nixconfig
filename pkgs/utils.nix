{
  lib,
  stdenv,
  AutoVirt,
  makeWrapper,
  python3,
  pciutils,
  coreutils,
  gnugrep,
  gnused,
  gawk,
  util-linux,
}:

stdenv.mkDerivation {
  pname = "nixvirt-utils";
  version = "1.0.0";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    python3
    pciutils
    coreutils
    gnugrep
    gnused
    gawk
    util-linux
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/nixvirt/scripts

    cp ${AutoVirt}/resources/scripts/Linux/evdev-auto.sh $out/share/nixvirt/scripts/
    cp ${AutoVirt}/resources/scripts/Linux/vbios-dumper.sh $out/share/nixvirt/scripts/

    chmod +x $out/share/nixvirt/scripts/*.sh

    # evdev-auto: prints XML snippets for evdev input passthrough
    makeWrapper $out/share/nixvirt/scripts/evdev-auto.sh $out/bin/nixvirt-evdev \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gnugrep
          gnused
          gawk
        ]
      }

    # vbios-dumper: dumps GPU VBIOS ROM
    makeWrapper $out/share/nixvirt/scripts/vbios-dumper.sh $out/bin/nixvirt-vbios-dumper \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          pciutils
        ]
      }

  '';

  meta = {
    description = "nixvirt scripts";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
