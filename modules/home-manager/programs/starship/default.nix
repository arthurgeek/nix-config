{ ... }:

{
  programs.starship = {
    enable = true;

    enableTransience = true;

    settings = {
      line_break.disabled = true;

      kubernetes = {
        disabled = false;
        detect_folders = [ "kubernetes" ];
      };
    };
  };
}
