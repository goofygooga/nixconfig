{
  lib,
  stdenv,
  autovirt,
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
  pname = "barely-metal-utils";
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
    mkdir -p $out/bin $out/share/barely-metal/scripts

    cp ${autovirt}/resources/scripts/Linux/evdev-auto.sh $out/share/barely-metal/scripts/
    cp ${autovirt}/resources/scripts/Linux/vbios-dumper.sh $out/share/barely-metal/scripts/

    chmod +x $out/share/barely-metal/scripts/*.sh

    # evdev-auto: prints XML snippets for evdev input passthrough
    makeWrapper $out/share/barely-metal/scripts/evdev-auto.sh $out/bin/barely-metal-evdev \
      --prefix PATH : ${lib.makeBinPath [
        coreutils
        gnugrep
        gnused
        gawk
      ]}

    # vbios-dumper: dumps GPU VBIOS ROM
    makeWrapper $out/share/barely-metal/scripts/vbios-dumper.sh $out/bin/barely-metal-vbios-dumper \
      --prefix PATH : ${lib.makeBinPath [
        coreutils
        pciutils
      ]}

  '';

  meta = {
    description = "BarelyMetal utility scripts for VM anti-detection";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}