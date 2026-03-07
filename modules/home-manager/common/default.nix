{ pkgs, lib, inputs, username, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.${username} = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
      ../programs/git
      ../programs/bat
      ../programs/fish
      ../programs/starship
      ../programs/lazygit
      ../programs/ssh
      ../programs/delta
      ../programs/direnv
      ../programs/wezterm
      ../programs/zoxide
    ];

    home = {
      username = username;
      homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
      stateVersion = "25.11";

      packages = with pkgs; [
        # CLI tools
        jq
        fzf
        eza
        neovim
        gnused
        ripgrep
        exiftool
        ast-grep

        # GUI apps
        obsidian
        spotify
        discord
        wezterm
      ]
      # On non-darwin, install via Nix (on macOS these use Homebrew
      # casks due to hardened runtime location checks)
      ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
        _1password-gui
        google-chrome
      ]
      ;
    };

    # Catppuccin
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "lavender";
    };
    programs.home-manager.enable = true;
  };
}
