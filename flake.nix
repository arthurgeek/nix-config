{
  description = "NixOS and nix-darwin configurations";

  # Every input is pinned to an immutable commit SHA so `nix flake update` is a
  # no-op; Renovate owns all bumps (see renovate.json). The trailing comment is
  # the "version" Renovate tracks: a release tag (datasource=github-releases) or
  # a branch name to follow (datasource=git-refs).
  inputs = {
    # nixpkgs
    # renovate: datasource=git-refs depName=https://github.com/NixOS/nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/8edc0c72e3a38faf5434e40d1f19431125fe4b30"; # nixpkgs-unstable

    # nix-darwin
    nix-darwin = {
      # renovate: datasource=git-refs depName=https://github.com/nix-darwin/nix-darwin
      url = "github:nix-darwin/nix-darwin/4cff07de74b50e64bdd68cd4e722ab5b6b35ee48"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager
    home-manager = {
      # renovate: datasource=git-refs depName=https://github.com/nix-community/home-manager
      url = "github:nix-community/home-manager/c58f54c733a7894d84fa2fdff26cc12088c4b78c"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-homebrew
    nix-homebrew = {
      # renovate: datasource=git-refs depName=https://github.com/zhaofengli/nix-homebrew
      url = "github:zhaofengli/nix-homebrew/c11cccfdd36dd69b5323d70d354b2853379c2426"; # main
    };
    homebrew-core = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-core
      url = "github:homebrew/homebrew-core/5ae87c5ca2f69f6f9d4a096465f5a28dfafe637f"; # main
      flake = false;
    };
    homebrew-cask = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-cask
      url = "github:homebrew/homebrew-cask/e2681c2424a1ccb8c2728860b997fdaa40dd9f26"; # main
      flake = false;
    };
    homebrew-barutsrb-tap = {
      # renovate: datasource=git-refs depName=https://github.com/BarutSRB/homebrew-tap
      url = "github:BarutSRB/homebrew-tap/ed66148f36a9b5458d705ed15b5f36a682ed72da"; # main
      flake = false;
    };

    # NixOS profiles to optimize settings for different hardware
    # renovate: datasource=git-refs depName=https://github.com/nixos/nixos-hardware
    hardware.url = "github:nixos/nixos-hardware/60a624466c08787ee8303393b7d4752d1826f14f"; # master

    # Secure Boot for NixOS: signs the boot chain with keys enrolled in firmware
    lanzaboote = {
      # renovate: datasource=github-releases depName=nix-community/lanzaboote
      url = "github:nix-community/lanzaboote/c1c5edd31802d181c8aa2c71588995d93425d650"; # v1.2.0
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Prebuilt nix-index database, for command-not-found hints and comma
    nix-index-database = {
      # renovate: datasource=git-refs depName=https://github.com/nix-community/nix-index-database
      url = "github:nix-community/nix-index-database/9a2dd40780eeab8543aa97c59c26f11267025616"; # main
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # stylix: one base16/base24 palette themes every supported program
    stylix = {
      # renovate: datasource=git-refs depName=https://github.com/nix-community/stylix
      url = "github:nix-community/stylix/2856c4c6a845b9bec98828ef197abe176e4806bb"; # master
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Colour schemes for stylix, in base16 and base24 (modules/common/theme.nix)
    # renovate: datasource=git-refs depName=https://github.com/tinted-theming/schemes
    tinted-schemes.url = "github:tinted-theming/schemes/3ac91137e879502c442ab89ba0f1a98077d0da9d"; # spec-0.11
    tinted-schemes.flake = false;

    # noctalia shell
    noctalia = {
      # renovate: datasource=github-releases depName=noctalia-dev/noctalia-shell
      url = "github:noctalia-dev/noctalia-shell/6ef43e2bf2f3d5b4205ec72a72e34a2ab76ce3b4"; # v5.2.1
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

    # Helix AI completion language server
    # renovate: datasource=github-releases depName=leona/helix-assist
    helix-assist.url = "github:leona/helix-assist/a4796433ae6d3c3b5da9484967fb209a9caea159"; # v1.0.12
    helix-assist.flake = false;

    # Local API bridge for Codex subscription OAuth
    # renovate: datasource=github-releases depName=router-for-me/CLIProxyAPI
    cli-proxy-api.url = "github:router-for-me/CLIProxyAPI/091ff27f31285ec4fd1dd5823b44f7f51fb8f48b"; # v8.0.24
    cli-proxy-api.flake = false;

    # claude-code plugins
    claude-plugins-official = {
      # renovate: datasource=git-refs depName=https://github.com/anthropics/claude-plugins-official
      url = "github:anthropics/claude-plugins-official/f359d43b406057f1a8cdbc4ea93b827642c162e6"; # main
      flake = false;
    };
    superpowers = {
      # renovate: datasource=github-releases depName=obra/superpowers
      url = "github:obra/superpowers/bb92a77741419a4ab5f06e711a283343f1ada0c3"; # v7.0.0
      flake = false;
    };
    openai-plugins = {
      # renovate: datasource=git-refs depName=https://github.com/openai/plugins
      url = "github:openai/plugins/0722921d5542fc593105c27bd52630babd8b8c2a"; # main
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

      # Release tag Renovate keeps in the trailing comment of an input's url
      # line (`foo.url = "github:…/<sha>"; # v1.2.3`). Packages built from a
      # source input read their version here, so a bump can't leave a stale
      # second copy behind. An input that follows a branch (`# main`) has no
      # release, so it gets nixpkgs' `0-unstable-<commit date>` instead.
      inputVersion =
        name:
        let
          lines = nixpkgs.lib.splitString "\n" (builtins.readFile ./flake.nix);
          matches = builtins.filter (m: m != null) (
            map (builtins.match "[[:space:]]*${name}\\.url = \"[^\"]+\"; # v?([^[:space:]]+)") lines
          );
          tag = builtins.head (builtins.head matches);
          date = inputs.${name}.lastModifiedDate;
        in
        if builtins.match "[0-9].*" tag != null then
          tag
        else
          "0-unstable-${builtins.substring 0 4 date}-${builtins.substring 4 2 date}-${builtins.substring 6 2 date}";

      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-linux"
      ];
    in
    {
      # For modules that build a source input themselves (e.g. cli-proxy-api).
      lib = { inherit inputVersion; };

      # Packages we build from a source input or patch on top of nixpkgs.
      # Exposed so the renovate-lock workflow can build every one of them on a
      # Renovate branch, refreshing vendor hashes and catching broken patches
      # before the bump is merged.
      packages = forAllSystems (system: {
        cli-proxy-api = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/cli-proxy-api.nix {
          src = inputs.cli-proxy-api;
          version = inputVersion "cli-proxy-api";
        };
      });

      nixosConfigurations = {
        rapture = mkNixosConfiguration "rapture" "arthur";
      };

      darwinConfigurations = {
        "columbia" = mkDarwinConfiguration "columbia" "arthurzapparoli";
      };
    };
}
