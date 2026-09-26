{
  description = "NixOS and nix-darwin configurations";

  # Every input is pinned to an immutable commit SHA so `nix flake update` is a
  # no-op; Renovate owns all bumps (see renovate.json). The trailing comment is
  # the "version" Renovate tracks: a release tag (datasource=github-releases) or
  # a branch name to follow (datasource=git-refs).
  inputs = {
    # nixpkgs
    # renovate: datasource=git-refs depName=https://github.com/NixOS/nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/35e212742ceab4ae1dcfbfd9039a39215c816e8e"; # nixpkgs-unstable

    # nix-darwin
    nix-darwin = {
      # renovate: datasource=git-refs depName=https://github.com/nix-darwin/nix-darwin
      url = "github:nix-darwin/nix-darwin/4cff07de74b50e64bdd68cd4e722ab5b6b35ee48"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager
    home-manager = {
      # renovate: datasource=git-refs depName=https://github.com/nix-community/home-manager
      url = "github:nix-community/home-manager/a3dfb887d40d134af29fa8e924ba85a3e3a99194"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-homebrew
    nix-homebrew = {
      # renovate: datasource=git-refs depName=https://github.com/zhaofengli/nix-homebrew
      url = "github:zhaofengli/nix-homebrew/c11cccfdd36dd69b5323d70d354b2853379c2426"; # main
    };
    homebrew-core = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-core
      url = "github:homebrew/homebrew-core/897cf5bc7ad88de665973df7bbb1d0b1e7c37a05"; # main
      flake = false;
    };
    homebrew-cask = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-cask
      url = "github:homebrew/homebrew-cask/f373be9edef93b6abceb1f397f5af56f4319e53e"; # main
      flake = false;
    };
    homebrew-barutsrb-tap = {
      # renovate: datasource=git-refs depName=https://github.com/BarutSRB/homebrew-tap
      url = "github:BarutSRB/homebrew-tap/ed66148f36a9b5458d705ed15b5f36a682ed72da"; # main
      flake = false;
    };

    # NixOS profiles to optimize settings for different hardware
    # renovate: datasource=git-refs depName=https://github.com/nixos/nixos-hardware
    hardware.url = "github:nixos/nixos-hardware/9ebcb7766700d7e006d9505247bd7ce0426f4232"; # master

    # Secure Boot for NixOS: signs the boot chain with keys enrolled in firmware
    lanzaboote = {
      # renovate: datasource=github-releases depName=nix-community/lanzaboote
      url = "github:nix-community/lanzaboote/c1c5edd31802d181c8aa2c71588995d93425d650"; # v1.2.0
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Prebuilt nix-index database, for command-not-found hints and comma
    nix-index-database = {
      # renovate: datasource=git-refs depName=https://github.com/nix-community/nix-index-database
      url = "github:nix-community/nix-index-database/9ad722673ab3b3f91f02135e53775825b240b869"; # main
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      url = "github:caelestia-dots/cli/82265df3665b40184e8bdc2165541e072c5a4971"; # v1.1.3
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

    # Opinionated Jujutsu configuration for stacked workflows
    # renovate: datasource=git-refs depName=https://github.com/LazyJJ-dev/LazyJJ
    lazyjj-config.url = "github:LazyJJ-dev/LazyJJ/0acb115dbb66821995ba04bc1b3854aa52d00dde"; # main
    lazyjj-config.flake = false;

    # Herdr plugins. These are source-only inputs; Nix builds and registers
    # adapted manifests without invoking upstream installers or updaters.
    # renovate: datasource=github-releases depName=jeffarese/herdr-bar
    herdr-bar.url = "github:jeffarese/herdr-bar/b57aa342f88f9db78f3deb20629ccebf162a6f57"; # v0.3.0
    herdr-bar.flake = false;
    # renovate: datasource=git-refs depName=https://github.com/JanTvrdik/herdr-command-palette
    herdr-command-palette.url = "github:JanTvrdik/herdr-command-palette/eab940018c2135ac23718efa11e23e9dddcd2a75"; # main
    herdr-command-palette.flake = false;
    # renovate: datasource=github-releases depName=qu8n/herdr-automatic-rename
    herdr-automatic-rename.url = "github:qu8n/herdr-automatic-rename/e241443d9bc29d717c0a9edec281f2b92692a279"; # v0.8.0
    herdr-automatic-rename.flake = false;
    # renovate: datasource=github-releases depName=smarzban/herdr-file-viewer
    herdr-file-viewer.url = "github:smarzban/herdr-file-viewer/647f03236d9aa20de0b07c9de0a951e13a1e59bf"; # v1.16.0
    herdr-file-viewer.flake = false;
    # renovate: datasource=github-releases depName=levi-qiao/herdr-agent-quota
    herdr-agent-quota.url = "github:levi-qiao/herdr-agent-quota/3b63f83762bc85521a68851b3432914fb6df3de0"; # v1.3.0
    herdr-agent-quota.flake = false;

    # Helix AI completion language server
    # renovate: datasource=github-releases depName=leona/helix-assist
    helix-assist.url = "github:leona/helix-assist/a4796433ae6d3c3b5da9484967fb209a9caea159"; # v1.0.12
    helix-assist.flake = false;

    # Local API bridge for Codex subscription OAuth
    # renovate: datasource=github-releases depName=router-for-me/CLIProxyAPI
    cli-proxy-api.url = "github:router-for-me/CLIProxyAPI/4b5f1eab25fca4b3815369a826e958e7c070a69e"; # v7.2.143
    cli-proxy-api.flake = false;

    # claude-code plugins
    claude-plugins-official = {
      # renovate: datasource=git-refs depName=https://github.com/anthropics/claude-plugins-official
      url = "github:anthropics/claude-plugins-official/c447c3207a425bc4e2a0d068435f64b0477ae981"; # main
      flake = false;
    };
    superpowers = {
      # renovate: datasource=github-releases depName=obra/superpowers
      url = "github:obra/superpowers/5bf4e78011075bcfc0dc295f0724994cd123ee71"; # v6.4.1
      flake = false;
    };
    openai-plugins = {
      # renovate: datasource=git-refs depName=https://github.com/openai/plugins
      url = "github:openai/plugins/1dc195897af4161d039b80d8471ec0a10c9bbc89"; # main
      flake = false;
    };
    openai-skills = {
      # renovate: datasource=git-refs depName=https://github.com/openai/skills
      url = "github:openai/skills/49f948faa9258a0c61caceaf225e179651397431"; # main
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
                  direnv = prev.direnv.overrideAttrs (_: {
                    doCheck = false;
                  });
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
