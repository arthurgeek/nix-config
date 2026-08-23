{
  userConfig,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/git
    ../programs/bat
    ../programs/btop
    ../programs/fish
    ../programs/starship
    ../programs/lazygit
    ../programs/ssh
    ../programs/delta
    ../programs/direnv
    ../programs/zoxide
    ../programs/helix
    ../programs/fzf

    ../programs/ghostty
    ../programs/rio
    ../programs/jq
    ../programs/eza
    ../programs/fastfetch
    ../programs/ripgrep
    ../programs/omniwm
    ../programs/claude-code
    ../programs/gh
    ../programs/glow
    ../programs/vscode
  ];

  # Nicely reload system units when changing configs
  systemd.user.startServices = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) "sd-switch";

  home = {
    username = userConfig.name;
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin then
        "/Users/${userConfig.name}"
      else
        "/home/${userConfig.name}";

    packages =
      with pkgs;
      [
        # CLI tools
        dust # visual du
        fd # find, but fast
        tldr # abridged man pages
        gnused
        exiftool
        ast-grep
        yq
      ]

      # On non-darwin, install via Nix (on macOS these use Homebrew
      # casks due to hardened runtime location checks)
      ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
        # 1Password is installed by the NixOS module, not here — home.packages
        # would omit the polkit policy and setgid helper it needs.
        google-chrome
      ];
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "${config.home.homeDirectory}/nix-config";
  };

  # Catppuccin
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "lavender";

    # catppuccin.enable turns on every port module, including ones for programs
    # we do not use. Its gemini-cli module sets `programs.gemini-cli.settings`,
    # which home-manager has renamed to `programs.antigravity-cli.settings`, so
    # it emits a rename warning on every rebuild. The setting is inert (we never
    # set `programs.gemini-cli.enable`), so just switch the port off. Drop this
    # once catppuccin/nix renames the module upstream.
    gemini-cli.enable = false;
  };
}
