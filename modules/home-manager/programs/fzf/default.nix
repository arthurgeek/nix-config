{ ... }:
{
  programs.fzf = {
    enable = true;
    # Fish integration handled by fzf-fish plugin
    enableFishIntegration = false;
  };
}
