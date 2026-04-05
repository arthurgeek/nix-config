{ ... }:

{
  programs.starship = {
    enable = true;

    enableTransience = true;

    settings = {
      kubernetes = {
        disabled = false;
        detect_folders = [ "kubernetes" ];
      };
    };
  };
}
