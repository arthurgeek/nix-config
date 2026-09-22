{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    # On macOS the application itself comes from the `visual-studio-code`
    # Homebrew cask. macOS App Management (TCC) refuses to let any process —
    # root included — modify a signed .app bundle, so once the store copy has
    # been launched it can never be deleted and `nix store gc` aborts the whole
    # collection on it. Settings and extensions live outside the bundle, so
    # home-manager still manages them from here.
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.vscode;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        mkhl.direnv
        rust-lang.rust-analyzer
      ];

      userSettings = {
        "editor.fontSize" = 16;
        "editor.formatOnSave" = true;
        "editor.inlayHints.enabled" = "on";
      };
    };
  };
}
