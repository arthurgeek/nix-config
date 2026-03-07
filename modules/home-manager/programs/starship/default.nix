{ ... }:

{
  programs.starship = {
    enable = true;

    settings = {
      line_break.disabled = true;

      kubernetes = {
        disabled = false;
        detect_folders = [ "kubernetes" ];
      };
    };
  };
}
