{
  description = "NixOS and nix-darwin configurations";

  # Every input is pinned to an immutable commit SHA so `nix flake update` is a
  # no-op; Renovate owns all bumps (see renovate.json). The trailing comment is
  # the "version" Renovate tracks: a release tag (datasource=github-releases) or
  # a branch name to follow (datasource=git-refs).
  inputs = {
    # nixpkgs
    # renovate: datasource=git-refs depName=https://github.com/NixOS/nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/02f5696b0e6097e589076d886b317b83ff0437d7"; # nixpkgs-unstable

    # nix-darwin
    nix-darwin = {
      # renovate: datasource=git-refs depName=https://github.com/nix-darwin/nix-darwin
      url = "github:nix-darwin/nix-darwin/4cff07de74b50e64bdd68cd4e722ab5b6b35ee48"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager
    home-manager = {
      # renovate: datasource=git-refs depName=https://github.com/nix-community/home-manager
      url = "github:nix-community/home-manager/87c391f49a34660de6010f35bb50fb1bf811be9f"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-homebrew
    nix-homebrew = {
      # renovate: datasource=git-refs depName=https://github.com/zhaofengli/nix-homebrew
      url = "github:zhaofengli/nix-homebrew/09a921d0181146cf6163ec2cc1db7b6fd539a885"; # main
      # Hold Homebrew < 5.1.14: that release added a utils/path.rb check that
      # rejects casks whose realpath resolves into /nix/store, how nix-homebrew
      # serves its read-only taps (zhaofengli/nix-homebrew#148, fix: PR #150).
      # The `<5.1.14` guard in renovate.json keeps Renovate from bumping past it.
      # renovate: datasource=github-releases depName=Homebrew/brew
      inputs.brew-src.url = "github:Homebrew/brew/d8deaca5574faf79a27f110caedc9e153709e628"; # 5.1.13
    };
    homebrew-core = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-core
      url = "github:homebrew/homebrew-core/2ef6d64f1a7487c0862b96aed7677e1ab9daad14"; # main
      flake = false;
    };
    homebrew-cask = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-cask
      url = "github:homebrew/homebrew-cask/8215483a291c1f87475f6e2457e80e474852dfe7"; # main
      flake = false;
    };
    homebrew-barutsrb-tap = {
      # renovate: datasource=git-refs depName=https://github.com/BarutSRB/homebrew-tap
      url = "github:BarutSRB/homebrew-tap/ed66148f36a9b5458d705ed15b5f36a682ed72da"; # main
      flake = false;
    };

    # NixOS profiles to optimize settings for different hardware
    # renovate: datasource=git-refs depName=https://github.com/nixos/nixos-hardware
    hardware.url = "github:nixos/nixos-hardware/d40fd26f323c898b0c195d41aa5efadd85f57832"; # master

    # catppuccin theme
    catppuccin = {
      # renovate: datasource=github-releases depName=catppuccin/nix
      url = "github:catppuccin/nix/096f4670cf078d810a931fae59b57db4cc3fb4d3"; # v26.05
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # noctalia shell
    noctalia = {
      # renovate: datasource=github-releases depName=noctalia-dev/noctalia-shell
      url = "github:noctalia-dev/noctalia-shell/c7b9197af77ff22bfb9a83c52a95643a1d90ca86"; # v5.1.0
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # caelestia shell
    # Follows nixpkgs, unlike hyprland above: there is no public binary cache
    # for caelestia and it builds quickshell from source either way, so not
    # following would buy a second full nixpkgs Qt6 closure for no benefit.
    caelestia-shell = {
      # renovate: datasource=github-releases depName=caelestia-dots/shell
      url = "github:caelestia-dots/shell/d999d4878ee4cec134168e60d913714566a8cfa6"; # v2.5.0
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

    # Codex CLI native binary distribution. Like nix-claude-code above, this
    # follows main live; codex-cli-nix tracks official Codex releases hourly,
    # while flake.lock keeps each configuration build reproducible.
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix"; # main
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-code plugins
    claude-plugins-official = {
      # renovate: datasource=git-refs depName=https://github.com/anthropics/claude-plugins-official
      url = "github:anthropics/claude-plugins-official/da823e86c8feef13b73b6712af11eadd38c992f6"; # main
      flake = false;
    };
    superpowers = {
      # renovate: datasource=github-releases depName=obra/superpowers
      url = "github:obra/superpowers/b36e0829c6d0140e93cfef2ca599b1b07d4a7797"; # v6.3.0
      flake = false;
    };
    openai-plugins = {
      # renovate: datasource=git-refs depName=https://github.com/openai/plugins
      url = "github:openai/plugins/1dc195897af4161d039b80d8471ec0a10c9bbc89"; # main
      flake = false;
    };
    # renovate: datasource=github-releases depName=oraios/serena
    serena.url = "github:oraios/serena/949a27ef1e5fda1a6e7b561e777bcece345c6ffd"; # v1.7.0
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
