{ ... }:
{
  programs.fzf = {
    enable = true;
    # Shell history is handled by Atuin; keep fzf integration disabled to prevent keybinding conflicts
    enableFishIntegration = false;
  };
}
