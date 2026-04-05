{ ... }:
{
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group"
      "--header"
      "--group-directories-first"
    ];
  };
}
