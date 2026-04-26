{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;

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
