{
  description = "NixOS and nix-darwin configurations";

  # Every input is pinned to an immutable commit SHA so `nix flake update` is a
  # no-op; Renovate owns all bumps (see renovate.json). The trailing comment is
  # the "version" Renovate tracks: a release tag (datasource=github-releases) or
  # a branch name to follow (datasource=git-refs).
  inputs = {
    # nixpkgs
    # renovate: datasource=git-refs depName=https://github.com/NixOS/nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/104240a772428cc2e20d8fd86c9ddbb886bbaff2"; # nixpkgs-unstable

    # nix-darwin
    nix-darwin = {
      # renovate: datasource=git-refs depName=https://github.com/nix-darwin/nix-darwin
      url = "github:nix-darwin/nix-darwin/15abb8c98f336cd8bd840d71059adebabe60bf04"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager
    home-manager = {
      # renovate: datasource=git-refs depName=https://github.com/nix-community/home-manager
      url = "github:nix-community/home-manager/cfba7ad5886b342b8dd63ba74354b3853ea4cfc9"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-homebrew
    nix-homebrew = {
      # renovate: datasource=git-refs depName=https://github.com/zhaofengli/nix-homebrew
      url = "github:zhaofengli/nix-homebrew/937ce52c7d046310571f3a070713804ead496843"; # main
      # Hold Homebrew < 5.1.14: that release added a utils/path.rb check that
      # rejects casks whose realpath resolves into /nix/store, how nix-homebrew
      # serves its read-only taps (zhaofengli/nix-homebrew#148, fix: PR #150).
      # The `<5.1.14` guard in renovate.json keeps Renovate from bumping past it.
      # renovate: datasource=github-releases depName=Homebrew/brew
      inputs.brew-src.url = "github:Homebrew/brew/d8deaca5574faf79a27f110caedc9e153709e628"; # 5.1.13
    };
    homebrew-core = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-core
      url = "github:homebrew/homebrew-core/4cd10f3021a06b624932fa33235204f2f68eecee"; # main
      flake = false;
    };
    homebrew-cask = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-cask
      url = "github:homebrew/homebrew-cask/27a6b5d01f50b1bfb1a8d6df95e3f45c9d058510"; # main
      flake = false;
    };
    homebrew-barutsrb-tap = {
      # renovate: datasource=git-refs depName=https://github.com/BarutSRB/homebrew-tap
      url = "github:BarutSRB/homebrew-tap/f6735364fa121deedce8617d1c77b0bbce3c2966"; # main
      flake = false;
    };

    # NixOS profiles to optimize settings for different hardware
    # renovate: datasource=git-refs depName=https://github.com/nixos/nixos-hardware
    hardware.url = "github:nixos/nixos-hardware/2e790b0a6be8ec2b76174ac0931b8ff11919ec98"; # master

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

    # caelestia shell
    # Follows nixpkgs, unlike hyprland above: there is no public binary cache
    # for caelestia and it builds quickshell from source either way, so not
    # following would buy a second full nixpkgs Qt6 closure for no benefit.
    caelestia-shell = {
      # renovate: datasource=github-releases depName=caelestia-dots/shell
      url = "github:caelestia-dots/shell/c99f9755770ee48c5ea613833bc5376b4f4f740e"; # v2.3.0
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.caelestia-cli.follows = "caelestia-cli";
    };

    # caelestia cli
    # Pinned here rather than left to caelestia-shell's own lock: upstream
    # declares it as an unpinned `github:caelestia-dots/cli` following main, so
    # `nix flake update` would move it and Renovate could not see it. The
    # `follows` above keeps the standalone CLI and the copy baked into the
    # shell's `with-cli` wrapper on the same rev.
    caelestia-cli = {
      # renovate: datasource=github-releases depName=caelestia-dots/cli
      url = "github:caelestia-dots/cli/0a3a4bb0f915f596c4e18e4ca3b00a6b2064442b"; # v1.1.2
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-code official binary distribution.
    # Intentionally NOT pinned to a SHA (unlike every other input above): this
    # follows `main` live, so `nix flake update nix-claude-code` re-locks it to
    # the latest commit on the branch. No Renovate annotation — there is no SHA
    # in the URL for it to bump.
    nix-claude-code = {
      url = "github:ryoppippi/nix-claude-code"; # main
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-code plugins
    claude-plugins-official = {
      # renovate: datasource=git-refs depName=https://github.com/anthropics/claude-plugins-official
      url = "github:anthropics/claude-plugins-official/340e33aef211d95769d252324854497af871dafe"; # main
      flake = false;
    };
    superpowers = {
      # renovate: datasource=github-releases depName=obra/superpowers
      url = "github:obra/superpowers/3dcbd5c4b48e02263fbf4a3c01e3fe4f81d584d9"; # v6.2.0
      flake = false;
    };
    # renovate: datasource=github-releases depName=oraios/serena
    serena.url = "github:oraios/serena/bcac0969fb8685783ea6d0f2642468fcc47e6395"; # v1.6.1
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
