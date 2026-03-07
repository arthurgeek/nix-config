{ pkgs, ... }:

{
  programs.lazygit = {
    enable = true;

    settings = {
      gui.nerdFontsVersion = "3";

      git = {
        pagers = [
          { pager = "delta --features 'default decorations' --paging=never"; }
        ];
        branchLogCmd = "git log --color=always {{branchName}} --";
        commit.signOff = true;
        parseEmoji = true;
        allBranchesLogCmds = [
          "git log --all --color=always"
        ];
      };

      os = {
        open = if pkgs.stdenv.hostPlatform.isDarwin then "open {{filename}}" else "xdg-open {{filename}}";
        editPreset = "nvim-remote";
      };
    };
  };
}
