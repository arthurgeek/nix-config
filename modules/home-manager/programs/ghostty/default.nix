{ pkgs, lib, ... }:
let
  font = pkgs.nerd-fonts.fira-code;
in
{
  home.packages = [ font ];

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    settings = {
      font-family = "FiraCode Nerd Font Mono";
      font-size = 18;
      macos-option-as-alt = true;
      # For ssh sessions: ssh-env forwards COLORTERM and TERM_PROGRAM (falling
      # back to TERM=xterm-256color), and ssh-terminfo installs Ghostty's
      # terminfo on a remote host that lacks it, on first connect.
      shell-integration-features = "ssh-env,ssh-terminfo";
    };
  };

  # stylix themes the colours only: it scales the font size by 4/3 on macOS
  # (18 -> 24), so the font settings above stay ours on both hosts.
  stylix.targets.ghostty.fonts.enable = false;
}
