# Variables (override these as needed)
HOSTNAME ?= $(shell hostname)
FLAKE ?= .#$(HOSTNAME)

.PHONY: help install-nix install-nix-darwin darwin-rebuild nixos-rebuild \
	nix-gc flake-update bootstrap-mac

help:
	@echo "Available targets:"
	@echo "  install-nix          - Install the Nix package manager"
	@echo "  install-nix-darwin   - Install nix-darwin using flake $(FLAKE)"
	@echo "  darwin-rebuild       - Rebuild the nix-darwin configuration"
	@echo "  nixos-rebuild        - Rebuild the NixOS configuration"
	@echo "  nix-gc               - Run Nix garbage collection"
	@echo "  flake-update         - Update flake inputs"
	@echo "  bootstrap-mac        - Install Nix and nix-darwin sequentially"

install-nix:
	@echo "Installing Nix..."
	@curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
	@echo "Nix installation complete."

install-nix-darwin:
	@echo "Installing nix-darwin..."
	@sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake $(FLAKE)
	@echo "nix-darwin installation complete."

darwin-rebuild:
	@echo "Rebuilding darwin configuration..."
	@sudo darwin-rebuild switch --flake $(FLAKE)
	@echo "Darwin rebuild complete."

nixos-rebuild:
	@echo "Rebuilding NixOS configuration..."
	@sudo nixos-rebuild switch --flake $(FLAKE)
	@echo "NixOS rebuild complete."

nix-gc:
	@echo "Collecting Nix garbage..."
	@nix-collect-garbage -d
	@echo "Garbage collection complete."

flake-update:
	@echo "Updating flake inputs..."
	@nix flake update
	@echo "Flake update complete."

bootstrap-mac: install-nix install-nix-darwin
