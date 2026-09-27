{ ... }:

{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      hyperlinks = true;
      # stylix has no delta target; highlight with the bat theme its bat
      # target generates from the system palette.
      syntax-theme = "base16-stylix";
    };
  };
}
