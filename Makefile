# Variables (override these as needed)
HOSTNAME ?= $(shell hostname)
FLAKE ?= .#$(HOSTNAME)

.PHONY: help install-nix install-nix-darwin darwin-rebuild nixos-rebuild \
	nix-gc flake-update bootstrap-mac

help:
	@echo "Available targets:"
	@echo "  install-nix          - Install the Nix package manager"
	@echo "  install-nix-darwin   - Install nix-darwin using flake $(FLAKE)"
	@echo "  darwin-rebuild       - Rebuild the nix-darwin configuration (via nh)"
	@echo "  nixos-rebuild        - Rebuild the NixOS configuration (via nh)"
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
	@nh darwin switch --ask --hostname $(HOSTNAME)
	@echo "Darwin rebuild complete."

nixos-rebuild:
	@echo "Rebuilding NixOS configuration..."
	@nh os switch --ask
	@echo "NixOS rebuild complete."

nix-gc:
	@echo "Collecting Nix garbage..."
	@nh clean all
	@echo "Garbage collection complete."

flake-update:
	@echo "Updating flake inputs..."
	@nix flake update
	@echo "Flake update complete."

bootstrap-mac: install-nix install-nix-darwin
