# nix-config

Declarative macOS system configuration using [nix-darwin](https://github.com/nix-darwin/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and [Homebrew](https://brew.sh/).

## Structure

```
flake.nix                       # Flake entry point
modules/
  darwin/                       # macOS system config (nix-darwin)
  home-manager/
    common/                     # Home Manager entry point
    programs/                   # Per-program configuration
```

## Usage

Build and switch:

```sh
darwin-rebuild switch --flake .#macbook
```

Update flake inputs:

```sh
nix flake update
```
