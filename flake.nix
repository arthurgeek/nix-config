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
      url = "github:nix-community/home-manager/a7c70cc290290f373f50cd820403833d250459ac"; # master
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
      url = "github:homebrew/homebrew-core/6f65e395e8a0b6f76a3f1869fe172eba40d1644c"; # main
      flake = false;
    };
    homebrew-cask = {
      # renovate: datasource=git-refs depName=https://github.com/homebrew/homebrew-cask
      url = "github:homebrew/homebrew-cask/76b1c40ab8dfc8f0bdbfdaad53c069eda7cc80bb"; # main
      flake = false;
    };
    homebrew-barutsrb-tap = {
      # renovate: datasource=git-refs depName=https://github.com/BarutSRB/homebrew-tap
      url = "github:BarutSRB/homebrew-tap/01ec4312fccc0d8287f15491ace8c9d90dc5b71b"; # main
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
      url = "github:anthropics/claude-plugins-official/36b00173da517876f9e574ef98f3564b0e86c25d"; # main
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
