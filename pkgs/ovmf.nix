{
  lib,
  stdenv,
  buildPackages,
  autovirt,
  edk2,
  biosVendor ? "American Megatrends International, LLC.",
  biosVersion ? "1.0",
  biosDate ? "01/01/2024",
  biosRevision ? "0x00010000",
  acpiOemId ? "ALASKA",
  acpiOemTableId ? "0x20202020324B4445",
  acpiOemRevision ? "0x00000002",
  acpiCreatorId ? "0x20202020",
  acpiCreatorRevision ? "0x01000013",

  # Boot logo: path to a BMP file, or null to use EDK2 default
  bootLogo ? null,

  nasm,
  acpica-tools,
  python3,
  bc,
  util-linux,
  fetchgit,
}:

let
  cpuLower = lib.toLower cpu;
  patchFile = "${autovirt}/patches/EDK2/Intel-edk2-stable202605.patch";
  pythonEnv = buildPackages.python3.withPackages (ps: [ ps.distlib ]);
  targetArch = "X64";
in
stdenv.mkDerivation {
  pname = "barely-metal-ovmf";
  version = "202605-barely-metal";

  # Sourced from nixpkgs' own edk2 package (edk2.src) rather than a
  # separately pinned flake input — see note in flake.nix history: the
  # previous `edk2-src` flake input was declared but never consumed here
  # and has been removed to avoid a stale, unused lock-file entry.
  src = fetchgit {
  url = "https://github.com/tianocore/edk2.git";
  rev = "edk2-stable202605";
  fetchSubmodules = true;
  hash = "sha256-sUqLocdX7lxN2pEdn84Cjh8pOzYqIeKqO144XhwKA30=";
};

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  nativeBuildInputs = [
    bc
    pythonEnv
    util-linux
    nasm
    acpica-tools
  ];

  hardeningDisable = [
    "format"
    "stackprotector"
    "pic"
    "fortify"
  ];
  env.GCC_BIN = stdenv.cc.targetPrefix;
  env.GCC_X64_PREFIX = stdenv.cc.targetPrefix;

  prePatch = ''
    rm -rf BaseTools
    ln -sv ${buildPackages.edk2}/BaseTools BaseTools
  '';

  postPatch = ''
    patch -p1 < ${patchFile}

    # spoof_smbios: SMBIOS Type 0 (BIOS Information) strings
    sed -i \
      -e 's@VendStr = L"unknown";@VendStr = L"${biosVendor}";@' \
      -e 's@VersStr = L"unknown";@VersStr = L"${biosVersion}";@' \
      -e 's@DateStr = L"02/02/2022";@DateStr = L"${biosDate}";@' \
      OvmfPkg/SmbiosPlatformDxe/SmbiosPlatformDxe.c

    # spoof_acpi: MdeModulePkg Platform Configuration Database (PCD) entries
    # These control ACPI table defaults compiled into firmware
    sed -E -i \
      -e 's@(PcdFirmwareVendor)\|L"EDK II"\|@\1|L"${biosVendor}"|@' \
      -e 's@(PcdFirmwareRevision)\|0x00010000\|@\1|${biosRevision}|@' \
      -e 's@(PcdFirmwareVersionString)\|L""\|@\1|L"${biosVersion}"|@' \
      -e 's@(PcdFirmwareReleaseDateString)\|L""\|@\1|L"${biosDate}"|@' \
      -e 's@(PcdAcpiDefaultOemId)\|"[^"]*"\|@\1|"${acpiOemId}"|@' \
      -e 's@(PcdAcpiDefaultOemTableId)\|0x[0-9a-fA-F]+\|@\1|${acpiOemTableId}|@' \
      -e 's@(PcdAcpiDefaultOemRevision)\|0x[0-9a-fA-F]+\|@\1|${acpiOemRevision}|@' \
      -e 's@(PcdAcpiDefaultCreatorId)\|0x[0-9a-fA-F]+\|@\1|${acpiCreatorId}|@' \
      -e 's@(PcdAcpiDefaultCreatorRevision)\|0x[0-9a-fA-F]+\|@\1|${acpiCreatorRevision}|@' \
      MdeModulePkg/MdeModulePkg.dec

    # Sanity check: fail the build loudly if none of the PCD substitutions
    # above actually matched anything (e.g. after a nixpkgs edk2 version bump
    # renames/reformats these lines), rather than silently shipping a build
    # with stock ACPI/BIOS identifiers.
    if ! grep -q '${acpiOemId}' MdeModulePkg/MdeModulePkg.dec; then
      echo "ERROR: PcdAcpiDefaultOemId substitution did not match in MdeModulePkg.dec" >&2
      exit 1
    fi
    if ! grep -q '${biosVendor}' OvmfPkg/SmbiosPlatformDxe/SmbiosPlatformDxe.c; then
      echo "ERROR: BIOS vendor substitution did not match in SmbiosPlatformDxe.c" >&2
      exit 1
    fi

    # spoof_bochs_strings: Scrub "Bochs" strings from QemuVideoDxe
    # (compiled into firmware binary, detectable by scanners that read raw FIRM/UEFI tables on Windows)
    bochs_scrub_matched=0
    for f in OvmfPkg/QemuVideoDxe/Driver.c OvmfPkg/QemuVideoDxe/Qemu.h OvmfPkg/QemuVideoDxe/Initialize.c OvmfPkg/QemuVideoDxe/Gop.c; do
      if [ -f "$f" ]; then
        if grep -qi 'bochs' "$f"; then
          bochs_scrub_matched=1
        fi
        sed -i \
          -e 's/BochsRead/VgaRegRead/g' \
          -e 's/BochsWrite/VgaRegWrite/g' \
          -e 's/InitializeBochsGraphicsMode/InitializeStdGraphicsMode/g' \
          -e 's/QemuVideoBochsModeSetup/QemuVideoStdModeSetup/g' \
          -e 's/QemuVideoBochsModes/QemuVideoStdModes/g' \
          -e 's/QemuVideoBochsAddMode/QemuVideoStdAddMode/g' \
          -e 's/QemuVideoBochsEdid/QemuVideoStdEdid/g' \
          -e 's/QEMU_VIDEO_BOCHS_MODE_COUNT/QEMU_VIDEO_STD_MODE_COUNT/g' \
          -e 's/QEMU_VIDEO_BOCHS_MMIO/QEMU_VIDEO_STD_MMIO/g' \
          -e 's/QEMU_VIDEO_BOCHS/QEMU_VIDEO_STD/g' \
          -e 's/QEMU_VIDEO_BOCHS_MODES/QEMU_VIDEO_STD_MODES/g' \
          -e 's/BochsId/VgaRegId/g' \
          -e 's/"Bochs/"Std/g' \
          -e 's/"Skipping Bochs/"Skipping Std/g' \
          -e 's/"Adding Bochs/"Adding Std/g' \
          -e 's/"QemuVideo: BochsID/"QemuVideo: VgaRegID/g' \
          "$f"
      fi
    done

    # Sanity check: this loop previously failed silently if none of the
    # QemuVideoDxe files existed or matched (e.g. after an edk2 version bump
    # restructures OvmfPkg). Warn rather than fail here since a missing Bochs
    # string isn't necessarily fatal, but it should not go unnoticed.
    if [ "$bochs_scrub_matched" -eq 0 ]; then
      echo "WARNING: no 'Bochs' strings found in QemuVideoDxe sources — scrub step was a no-op. Check OvmfPkg/QemuVideoDxe/ still matches expected layout." >&2
    fi

    # spoof_bochs_debug_port: Remove Bochs debug port magic reference
    sed -i 's/BOCHS_DEBUG_PORT_MAGIC/STD_DEBUG_PORT_MAGIC/g' \
      OvmfPkg/Library/PlatformDebugLibIoPort/DebugIoPortQemu.c 2>/dev/null || true

    # spoof_boot_logo: Replace EDK2/Tux boot logo with host BGRT image (removes EDK2/UEFI fingerprint)
    ${lib.optionalString (bootLogo != null) ''
      cp -v ${bootLogo} MdeModulePkg/Logo/Logo.bmp
    ''}
  '';

  configurePhase = ''
    runHook preConfigure
    export WORKSPACE="$PWD"
    . ${buildPackages.edk2}/edksetup.sh BaseTools
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    build \
      -p OvmfPkg/OvmfPkgX64.dsc \
      -a ${targetArch} \
      -t GCC \
      -b RELEASE \
      -n $NIX_BUILD_CORES \
      -s \
      -D SECURE_BOOT_ENABLE=TRUE \
      -D SMM_REQUIRE=TRUE \
      -D TPM1_ENABLE=TRUE \
      -D TPM2_ENABLE=TRUE \
      -D FD_SIZE_4MB \
      -D NETWORK_IP6_ENABLE=TRUE

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/FV
    cp -v Build/OvmfX64/RELEASE_GCC/FV/OVMF_CODE.fd $out/FV/
    cp -v Build/OvmfX64/RELEASE_GCC/FV/OVMF_VARS.fd $out/FV/
    cp -v Build/OvmfX64/RELEASE_GCC/FV/OVMF.fd $out/FV/

    runHook postInstall
  '';

  enableParallelBuilding = true;
  doCheck = false;
  requiredSystemFeatures = [ "big-parallel" ];

  passthru = {
    firmware = "${placeholder "out"}/FV/OVMF_CODE.fd";
    variables = "${placeholder "out"}/FV/OVMF_VARS.fd";
  };

  meta = {
    description = "OVMF/EDK2 firmware with comprehensive anti-VM-detection patches (BarelyMetal/AutoVirt)";
    homepage = "https://github.com/Scrut1ny/AutoVirt";
    license = lib.licenses.bsd2;
    platforms = [ "x86_64-linux" ];
  };
}