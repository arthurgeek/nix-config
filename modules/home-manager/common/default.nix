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
        gnused
        exiftool
        ast-grep
        yq
      ]

      # On non-darwin, install via Nix (on macOS these use Homebrew
      # casks due to hardened runtime location checks)
      ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
        _1password-gui
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
  };
}
