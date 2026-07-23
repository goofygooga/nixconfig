{
  lib,
  qemu,
  autovirt,
  fetchurl,
  acpiOemId ? "ACRSYS",
  acpiOemTableId ? "ACRPRDCT",
  acpiCreatorId ? "AMI ",
  acpiPmProfile ? 1,
  smbiosManufacturer ? "Advanced Micro Devices, Inc.",
  spoofModels ? true,
  spoofUsbSerials ? false,
  ideModel ? null,
  nvmeModel ? null,
  cdModel ? null,
  cfataModel ? null,
}:
let
  # Comprehensive realistic drive model collections (auto-select if not specified)
  ideModels = [
    "Samsung SSD 970 EVO 1TB"
    "Samsung SSD 860 QVO 1TB"
    "Samsung SSD 850 PRO 1TB"
    "Samsung SSD T7 Touch 1TB"
    "Samsung SSD 840 EVO 1TB"
    "WD Blue SN570 NVMe SSD 1TB"
    "WD Black SN850 NVMe SSD 1TB"
    "WD Green 1TB SSD"
    "WD Blue 3D NAND 1TB SSD"
    "Crucial P3 1TB PCIe 3.0 3D NAND NVMe SSD"
    "Seagate BarraCuda SSD 1TB"
    "Seagate FireCuda 520 SSD 1TB"
    "Seagate IronWolf 110 SSD 1TB"
    "SanDisk Ultra 3D NAND SSD 1TB"
    "Seagate Fast SSD 1TB"
    "Crucial MX500 1TB 3D NAND SSD"
    "Crucial P5 Plus NVMe SSD 1TB"
    "Crucial BX500 1TB 3D NAND SSD"
    "Crucial P3 1TB PCIe 3.0 3D NAND NVMe SSD"
    "Kingston A2000 NVMe SSD 1TB"
    "Kingston KC2500 NVMe SSD 1TB"
    "Kingston A400 SSD 1TB"
    "Kingston HyperX Savage SSD 1TB"
    "SanDisk SSD PLUS 1TB"
    "SanDisk Ultra 3D 1TB NAND SSD"
  ];

  nvmeModels = [
    "Samsung 990 PRO 2TB"
    "Kingston Canvas React Plus"
    "WD Black SN850X"
    "Crucial P5 Plus"
    "Sabrent Rocket Extreme"
  ];

  cdModels = [
    "HL-DT-ST BD-RE WH16NS60"
    "HL-DT-ST DVDRAM GH24NSC0"
    "HL-DT-ST BD-RE BH16NS40"
    "HL-DT-ST DVD+-RW GT80N"
    "HL-DT-ST DVD-RAM GH22NS30"
    "HL-DT-ST DVD+RW GCA-4040N"
    "Pioneer BDR-XD07B"
    "Pioneer DVR-221LBK"
    "Pioneer BDR-209DBK"
    "Pioneer DVR-S21WBK"
    "Pioneer BDR-XD05B"
    "ASUS BW-16D1HT"
    "ASUS DRW-24B1ST"
    "ASUS SDRW-08D2S-U"
    "ASUS BC-12D2HT"
    "ASUS SBW-06D2X-U"
    "Samsung SH-224FB"
    "Samsung SE-506BB"
    "Samsung SH-B123L"
    "Samsung SE-208GB"
    "Samsung SN-208DB"
    "Sony NEC Optiarc AD-5280S"
    "Sony DRU-870S"
    "Sony BWU-500S"
    "Sony NEC Optiarc AD-7261S"
    "Sony AD-7200S"
    "Lite-On iHAS124-14"
    "Lite-On iHBS112-04"
    "Lite-On eTAU108"
    "Lite-On iHAS324-17"
    "Lite-On eBAU108"
    "HP DVD1260i"
    "HP DVD640"
    "HP BD-RE BH30L"
    "HP DVD Writer 300n"
    "HP DVD Writer 1265i"
  ];

  cfataModels = [
    "SanDisk Ultra microSDXC UHS-I"
    "Samsung EVO Select microSDXC"
    "Kingston Canvas React Plus microSD"
    "Lexar Professional 1066x microSDXC"
  ];

  # Select models: use provided value or pick first from list
  selectedIdeModel = if ideModel != null then ideModel else lib.head ideModels;
  selectedNvmeModel = if nvmeModel != null then nvmeModel else lib.head nvmeModels;
  selectedCdModel = if cdModel != null then cdModel else lib.head cdModels;
  selectedCfataModel = if cfataModel != null then cfataModel else lib.head cfataModels;
in
(qemu.override {
  hostCpuTargets = [ "x86_64-softmmu" ];
  smbdSupport = false;
  spiceSupport = true;
  usbredirSupport = true;
}).overrideAttrs
  (old: rec {
    pname = "barely-metal-qemu";
    version = "11.0.2";
    configureFlags = (old.configureFlags or [ ]) ++ [
      "--target-list=x86_64-softmmu"
      "--enable-libusb"
      "--enable-usb-redir"
      "--enable-spice"
      "--enable-spice-protocol"
      "--disable-werror"
      "--disable-docs"
    ];
    src = fetchurl {
      url = "https://download.qemu.org/qemu-${version}.tar.xz";
      hash = "sha256-N0X26oji6H/g3IOLKx1OCncL9I4BodWhhoQqH/92zPU=";
    };
    patches = (old.patches or [ ]) ++ [
      "${autovirt}/patches/QEMU/Intel-v11.0.2.patch"
      ./extpatches/qemu-rtl8125-rel.patch
    ];

    postPatch = (old.postPatch or "") + ''
      # spoof_acpi: ACPI OEM identifiers and PM profile
      sed -i \
        -e 's/\(#define ACPI_BUILD_APPNAME6 \)"[^"]*"/\1"${acpiOemId}"/' \
        -e 's/\(#define ACPI_BUILD_APPNAME8 \)"[^"]*"/\1"${acpiOemTableId}"/' \
        include/hw/acpi/aml-build.h

      if ! grep -q '${acpiOemId}' include/hw/acpi/aml-build.h; then
        echo "ERROR: ACPI_BUILD_APPNAME6 substitution did not match in aml-build.h" >&2
        exit 1
      fi

      # Replace ACPI creator ID
      sed -i 's/"ACPI"/"${acpiCreatorId}"/g' hw/acpi/aml-build.c

      # Set PM Profile: 1 = Desktop, 2 = Mobile
      ${lib.optionalString (acpiPmProfile == 2) ''
        sed -i 's/1 \/\* Desktop \*\/, 1/2 \/\* Mobile \*\/, 1/' hw/acpi/aml-build.c
      ''}

      # spoof_hypervisor_vendor: Remove QEMU hypervisor vendor identity from FADT
      sed -i 's/build_append_padded_str(tbl, "QEMU", 8/build_append_padded_str(tbl, "", 8/' hw/acpi/aml-build.c

      # spoof_smbios: processor manufacturer
      sed -i \
        "s/smbios_set_defaults(\"[^\"]*\",/smbios_set_defaults(\"${smbiosManufacturer}\",/" \
        hw/i386/fw_cfg.c

      if ! grep -q '${smbiosManufacturer}' hw/i386/fw_cfg.c; then
        echo "ERROR: smbios_set_defaults substitution did not match in fw_cfg.c" >&2
        exit 1
      fi

      # spoof_models: realistic drive model strings
      ${lib.optionalString spoofModels ''
        # CD/DVD models
        sed -i -E \
          's/"HL-DT-ST BD-RE WH16NS60"/"${selectedCdModel}"/' \
          hw/ide/core.c

        # CompactFlash/microSD models
        sed -i -E \
          's/"Hitachi HMS360404D5CF00"/"${selectedCfataModel}"/' \
          hw/ide/core.c

        # IDE/SATA SSD models
        sed -i -E \
          's/"Samsung SSD 980 500GB"/"${selectedIdeModel}"/' \
          hw/ide/core.c

        # NVMe models
        sed -i -E \
          's/"NVMe Ctrl"/"${selectedNvmeModel}"/' \
          hw/nvme/ctrl.c

        # Verify all substitutions succeeded
        if ! grep -q '${selectedIdeModel}' hw/ide/core.c; then
          echo "ERROR: IDE default model substitution did not match in hw/ide/core.c" >&2
          exit 1
        fi
        if ! grep -q '${selectedNvmeModel}' hw/nvme/ctrl.c; then
          echo "ERROR: NVMe model substitution did not match in hw/nvme/ctrl.c" >&2
          exit 1
        fi
      ''}

      # spoof_serials: randomize USB device serial strings.
      #
      # NOTE: this previously drew from /dev/urandom at build time, which makes
      # the derivation impure/non-reproducible — two builds from the exact same
      # inputs would produce different store contents (same input hash, but
      # divergent output), which defeats binary-cache reuse and CI caching, and
      # is generally not how Nix derivations are supposed to behave.
      #
      # Instead, derive a per-string-position value deterministically from the
      # derivation's own fixed inputs (acpiOemId/smbiosManufacturer/version),
      # via a stable hash. This keeps the output fully reproducible for a given
      # set of option values while still varying the placeholder serials so
      # they don't all read as the identical stock QEMU string.
      ${lib.optionalString spoofUsbSerials ''
        seed_base="${acpiOemId}-${smbiosManufacturer}-${version}"
        for f in hw/usb/*.c; do
          for pat in STRING_SERIALNUMBER STR_SERIALNUMBER STR_SERIAL_MOUSE STR_SERIAL_TABLET STR_SERIAL_KEYBOARD STR_SERIAL_COMPAT; do
            while IFS= read -r lineno; do
              serial=$(printf '%s' "$seed_base-$f-$pat-$lineno" | sha256sum | cut -c1-10 | tr 'a-f' 'A-F')
              sed -r -i "''${lineno}s/(\[\s*$pat\s*\]\s*=\s*\")[^\"]*(\")/\1$serial\2/" "$f"
            done < <(grep -n "$pat" "$f" | grep -oP '^\d+')
          done
        done
      ''}
    '';
    outputs = [ "out" ];


    postInstall = (old.postInstall or "") + ''
      ln -sf $out/bin/qemu-system-x86_64 $out/bin/qemu-kvm
    '';

    meta = (old.meta or { }) // {
      description = "QEMU with comprehensive anti-VM-detection patches (BarelyMetal/AutoVirt)";
      mainProgram = "qemu-system-x86_64";
    };
  })
