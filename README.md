# nixconfig

A comprehensive NixOS system configuration with Noctalia desktop shell integration, featuring hardware-accelerated plugins and modern desktop utilities.

**Language Composition:** QML (80.2%) | Nix (18.6%) | Shell (1.2%)

## 📋 Overview

This repository contains a complete NixOS system configuration (`nixconfig`) centered around the **Noctalia** desktop shell. It includes a curated collection of QML-based plugins for modern Linux desktop features, integrated through Nix modules and Home Manager.

## 🎨 Features

- **Modular Nix Configuration**: Cleanly separated modules for boot, system, and home management
- **Noctalia Desktop Shell**: Professional, modern desktop environment with extensible plugin architecture
- **Hardware Integration Plugins**:
  - 🔋 **Battery & Power Management**: Real-time diagnostics, power profiles switcher, and hardware charge thresholds
  - 🎨 **NVibrant**: NVIDIA digital vibrance (color saturation) control
  - 🎥 **Screen Recorder**: Hardware-accelerated recording with replay buffer support
- **Modern Linux Utilities**: Integration with CachyOS kernel, Chaotic-CX packages, and community flakes
- **Home Manager Integration**: User-level configuration for `lordofchaos` user

## 📁 Directory Structure

```
.
├── flake.nix                 # Flake configuration and outputs
├── flake.lock               # Locked dependency versions
├── modules/                 # Reusable NixOS modules
│   ├── boot.nix            # Boot configuration
│   └── noctalia.nix        # Noctalia desktop shell setup
├── hosts/                   # Host-specific configurations
│   └── default/
│       ├── configuration.nix # Main system configuration
│       └── home/
│           ├── home.nix     # Home Manager user configuration
│           └── dotfiles/    # User dotfiles and plugins
│               └── noctalia/
│                   └── plugins/ # QML-based desktop plugins
└── .vscode/                # VSCode settings
```

## 🔧 System Inputs

The configuration pulls from multiple flake inputs:

| Input | Purpose |
|-------|---------|
| `nixpkgs` | Official NixOS packages (unstable) |
| `home-manager` | User-level declarative configuration |
| `barely-metal` | Custom flake for bare-metal utilities |
| `nixos-facter-modules` | Hardware auto-detection modules |
| `nix-cachyos-kernel` | Optimized CachyOS Linux kernel |
| `chaotic` | Chaotic-CX packages (AUR-inspired) |
| `noctalia` | Noctalia desktop shell (legacy-v4) |
| `grub2-themes` | GRUB bootloader themes |
| `SilentSDDM` | Silent SDDM login manager |

## 🚀 Getting Started

### Prerequisites

- NixOS 24.05 or later
- Flakes enabled (`experimental-features = nix-command flakes` in `/etc/nix/nix.conf`)
- x86_64-linux architecture

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/goofygooga/nixconfig.git
   cd nixconfig
   ```

2. Apply the configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#default
   ```

3. Log out and back in to activate Noctalia desktop shell.

## 🔌 Built-in Plugins

### Battery & Power Management
Real-time battery diagnostics with power profile switching and hardware threshold control.
- **Live diagnostics**: Charge %, charging state, power draw (Watts)
- **Power profiles**: Quick toggle between power-saver, balanced, and performance
- **Hardware thresholds**: Adjust battery charge ceiling (50%-100%)

**Requirements**: `powerprofilesctl`, modern laptop kernel (5.17+)

[📖 Full Documentation](hosts/default/home/dotfiles/noctalia/plugins/battery-and-power-management/README.md)

### NVibrant
One-click NVIDIA digital vibrance (color saturation) control.
- Multi-monitor support
- State persistence across restarts
- Configurable levels (0–1023)

**Requirements**: NVIDIA GPU, [nvibrant](https://github.com/Tremeschin/nvibrant)

[📖 Full Documentation](hosts/default/home/dotfiles/noctalia/plugins/nvibrant/README.md)

### Screen Recorder
Hardware-accelerated screen recording with replay buffer.
- Multiple video codecs: H264, HEVC, AV1, VP8, VP9, HDR variants
- Adjustable frame rates (30-240 FPS)
- Multiple audio sources (system, microphone, both)
- Replay buffer: Retroactively save last N seconds

**Requirements**: `gpu-screen-recorder`, `xdg-desktop-portal`

[📖 Full Documentation](hosts/default/home/dotfiles/noctalia/plugins/screen-recorder/README.md)

## 📝 Code Audit Summary

### ✅ Strengths

1. **Well-Organized Module Structure**: Clean separation of concerns with dedicated modules for boot, system, and home configs
2. **Comprehensive Plugin Documentation**: Each plugin includes clear installation, usage, and troubleshooting guides
3. **Flake Dependency Management**: Proper input pinning with locked versions via `flake.lock`
4. **Home Manager Integration**: User-level configuration properly scoped to `lordofchaos` user
5. **Modern Tooling**: Use of CachyOS kernel overlays and Chaotic-CX packages for cutting-edge utilities

### 🔍 Audit Findings

| Finding | Severity | Details | Recommendation |
|---------|----------|---------|-----------------|
| Missing root README | Low | Repository lacked top-level documentation | ✅ Added this README |
| Description typo | Low | Repository description: "My nix confog" | Consider updating to "NixOS Configuration with Noctalia Desktop" |
| Flake outputs minimal | Medium | Only `nixosConfigurations.default` exported; no dev shells or standalone module exports | Consider exporting individual modules for external use |
| No CONTRIBUTING.md | Low | No contribution guidelines | Consider adding for open-source collaboration |
| No LICENSE file | Medium | Unlicensed repository | Recommend adding MIT or GPL-3.0 license |

### 💡 Suggestions for Improvement

1. **Add Development Environment**: Create a `devShell` in flake.nix for contributors
2. **Export Reusable Modules**: Allow others to import `modules.boot` and `modules.noctalia` separately
3. **Add Installation Variants**: Support multiple hosts/configurations beyond the default
4. **Document User Setup**: Add post-installation guide for first-time Noctalia users
5. **Add Secrets Management**: Consider integrating `sops-nix` or `agenix` for sensitive data

## 🏗️ Configuration Architecture

```
flake.nix (entry point)
    ├── nixpkgs (unstable)
    ├── home-manager
    ├── noctalia (desktop shell)
    └── ... other inputs
            ↓
        nixosConfigurations.default
            ├── modules/boot.nix
            ├── modules/noctalia.nix
            ├── hosts/default/configuration.nix
            └── home-manager
                └── lordofchaos user
                    ├── home.nix
                    └── dotfiles/noctalia/plugins/
                        ├── battery-and-power-management/
                        ├── nvibrant/
                        └── screen-recorder/
```

## 📚 Documentation

- [Battery & Power Management Plugin](hosts/default/home/dotfiles/noctalia/plugins/battery-and-power-management/README.md)
- [NVibrant Plugin](hosts/default/home/dotfiles/noctalia/plugins/nvibrant/README.md)
- [Screen Recorder Plugin](hosts/default/home/dotfiles/noctalia/plugins/screen-recorder/README.md)

## 🐛 Troubleshooting

### Noctalia not appearing after rebuild
```bash
# Restart the display manager
sudo systemctl restart display-manager

# Or log out and back in to your session
```

### Plugin not loading
1. Verify the plugin is in `~/.config/noctalia/plugins/`
2. Check Noctalia logs: `journalctl -u noctalia`
3. Reload config: Settings → System → Reload Configuration

### Build failures
```bash
# Update flake inputs
nix flake update

# Clean and rebuild
nix-store --gc
sudo nixos-rebuild switch --flake .#default
```

## 📞 Support & Contributing

This is a personal configuration repository. For issues with specific components:
- **Noctalia**: https://github.com/noctalia-dev/noctalia-shell
- **NixOS**: https://discourse.nixos.org
- **Nix Flakes**: https://nixos.wiki/wiki/Flakes

## 📄 License

This repository is currently unlicensed. Consider choosing a license (MIT, GPL-3.0, or similar) and adding a LICENSE file.

---

**Last Updated**: July 2026  
**Configuration Style**: Modular, Flake-based NixOS with Home Manager
