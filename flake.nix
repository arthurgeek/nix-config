{
  description = "nix-darwin configuration";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-homebrew
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # catpuccin theme
    catppuccin.url = "github:catppuccin/nix";

    # noctalia shell
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, home-manager, catppuccin, noctalia, noctalia-qs }:
  let
    # Nixpkgs configuration
    nixpkgsConfig = {
      allowUnfree = true;
    };

    configuration = {
      imports = [
        ./modules/darwin
      ];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#macbook
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs;
        username = "arthurzapparoli";
      };
      modules = [
        { nixpkgs.config = nixpkgsConfig; }
        configuration
        ./modules/home-manager/common
      ];
    };

    # Build NixOS using:
    # $ nixos-rebuild switch --flake .#nixos
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        username = "arthur";
      };
      modules = [
        { nixpkgs.config = nixpkgsConfig; }
        ./modules/nixos
        ./modules/nixos/desktop/niri
        ./modules/home-manager/common
        ./modules/home-manager/desktop/niri
      ];
    };
  };
}
