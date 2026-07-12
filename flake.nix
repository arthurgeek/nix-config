{
  description = "NixOS and nix-darwin configurations";

  # Every input is pinned to an immutable commit SHA so `nix flake update` is a
  # no-op; Renovate owns all bumps (see renovate.json). The trailing comment is
  # the "version" Renovate tracks: a release tag (datasource=github-releases) or
  # a branch name to follow (datasource=git-refs).
  inputs = {
    # nixpkgs
    # renovate: datasource=git-refs depName=https://github.com/NixOS/nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/3e41b24abd260e8f71dbe2f5737d24122f972158"; # nixpkgs-unstable

    # nix-darwin
    nix-darwin = {
      # renovate: datasource=git-refs depName=https://github.com/nix-darwin/nix-darwin
      url = "github:nix-darwin/nix-darwin/a1fa429e945becaf60468600daf649be4ba0350c"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager
    home-manager = {
      # renovate: datasource=git-refs depName=https://github.com/nix-community/home-manager
      url = "github:nix-community/home-manager/979bfee6e1a7996fc395270d54c9b59e88762494"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-homebrew
    nix-homebrew = {
      # renovate: datasource=git-refs depName=https://github.com/zhaofengli/nix-homebrew
      url = "github:zhaofengli/nix-homebrew/60641da8324e6a1af716a0340d901ccb131c91ef"; # main
      # Hold Homebrew < 5.1.14: that release added a utils/path.rb check that
      # rejects casks whose realpath resolves into /nix/store, how nix-homebrew
      # serves its read-only taps (zhaofengli/nix-homebrew#148, fix: PR #150).
      # The `<5.1.14` guard in renovate.json keeps Renovate from bumping past it.
      # renovate: datasource=github-releases depName=Homebrew/brew
      inputs.brew-src.url = "github:Homebrew/brew/d8deaca5574faf79a27f110caedc9e153709e628"; # 5.1.13
    };
    homebrew-core = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-core
      url = "github:homebrew/homebrew-core/d3653ba851f7eacb4daca1b213926d5107b5e9d9"; # main
      flake = false;
    };
    homebrew-cask = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-cask
      url = "github:homebrew/homebrew-cask/eb26892fc3a1a7cfb32c15d0f5bb8bcb2ff93109"; # main
      flake = false;
    };
    homebrew-barutsrb-tap = {
      # renovate: datasource=git-refs depName=https://github.com/BarutSRB/homebrew-tap
      url = "github:BarutSRB/homebrew-tap/6bccadc35bdba61c3a4a981301f173e69fbfa73d"; # main
      flake = false;
    };

    # NixOS profiles to optimize settings for different hardware
    # renovate: datasource=git-refs depName=https://github.com/nixos/nixos-hardware
    hardware.url = "github:nixos/nixos-hardware/08018c72174a4df5657f8d94178ac69fb9c243e5"; # master

    # catppuccin theme
    catppuccin = {
      # renovate: datasource=github-releases depName=catppuccin/nix
      url = "github:catppuccin/nix/096f4670cf078d810a931fae59b57db4cc3fb4d3"; # v26.05
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # noctalia shell
    noctalia = {
      # renovate: datasource=github-releases depName=noctalia-dev/noctalia-shell
      url = "github:noctalia-dev/noctalia-shell/3abfa1fc09b62dc4cdeeb7b787886f075696f0b7"; # v4.7.7
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-code official binary distribution (tracks main)
    nix-claude-code = {
      # renovate: datasource=git-refs depName=https://github.com/ryoppippi/nix-claude-code
      url = "github:ryoppippi/nix-claude-code/3e63dfcebdc85e09c718ce2f0b58c7867bc45636"; # main
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-code plugins
    claude-plugins-official = {
      # renovate: datasource=git-refs depName=https://github.com/anthropics/claude-plugins-official
      url = "github:anthropics/claude-plugins-official/5fc2987a44918a455ef7dc583b51f8faf875c3ed"; # main
      flake = false;
    };
    superpowers = {
      # renovate: datasource=github-releases depName=obra/superpowers
      url = "github:obra/superpowers/896224c4b1879920ab573417e68fd51d2ccc9072"; # v6.0.3
      flake = false;
    };
    # renovate: datasource=github-releases depName=oraios/serena
    serena.url = "github:oraios/serena/2449313c0d7427275c4c66aedff7d4881782f713"; # v1.5.3
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      noctalia,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      # Nixpkgs configuration
      nixpkgsConfig = {
        allowUnfree = true;
      };

      # Define user configurations
      users = {
        arthur = {
          inherit (users.arthurzapparoli)
            email
            fullName
            ;
          name = "arthur";
        };
        arthurzapparoli = {
          name = "arthurzapparoli";
          email = "arthurgeek@users.noreply.github.com";
          fullName = "Arthur Zapparoli";
        };
      };

      # Function for NixOS system configuration
      mkNixosConfiguration =
        hostname: username:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = users.${username};
            nixosModules = "${self}/modules/nixos";
          };
          modules = [
            { nixpkgs.config = nixpkgsConfig; }
            ./hosts/${hostname}
          ];
        };

      # Function for nix-darwin system configuration
      mkDarwinConfiguration =
        hostname: username:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = users.${username};
            darwinModules = "${self}/modules/darwin";
          };
          modules = [
            {
              nixpkgs.config = nixpkgsConfig;
              nixpkgs.overlays = [
                # Workaround for macOS codesigning bug (NixOS/nixpkgs#507531, #513019).
                # Forces fish to rebuild locally so the binary gets a valid ad-hoc signature,
                # instead of using the broken one from the binary cache.
                (final: prev: {
                  fish = prev.fish.overrideAttrs (old: {
                    NIX_FORCE_LOCAL_REBUILD = "darwin-codesign-fix";
                  });
                  direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });
                })
              ];
            }
            ./hosts/${hostname}
          ];
        };
    in
    {
      nixosConfigurations = {
        rapture = mkNixosConfiguration "rapture" "arthur";
      };

      darwinConfigurations = {
        "columbia" = mkDarwinConfiguration "columbia" "arthurzapparoli";
      };
    };
}
