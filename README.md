# nix-config

Declarative NixOS and macOS system configuration using [nix-darwin](https://github.com/nix-darwin/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and [Homebrew](https://brew.sh/).

## Structure

```
flake.nix                       # Flake entry point
home/                           # Home Manager entry point
hosts/                          # Per-host Nix config
modules/
  darwin/                       # macOS system config (nix-darwin)
  nixos/                        # NixOS system config
  home-manager/
    common/                     # Home Manager common config
    desktop/                    # NixOS desktop config (niri, wayland, etc)
    programs/                   # Per-program configuration
```

## Usage

### Darwin

Install / bootstrap:

```sh
make bootstrap-mac
```

Build and switch:

```sh
make darwin-rebuild
```

### NixOS

```sh
make nixos-rebuild
```

### General

Update flake inputs:

```sh
make flake-update
```
