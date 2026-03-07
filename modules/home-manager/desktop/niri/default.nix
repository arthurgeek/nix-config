{ username, inputs, ... }:

{
  home-manager.users.${username} = {
    imports = [
      inputs.noctalia.homeModules.default
      ../wayland-common
    ];

    programs.noctalia-shell = {
      enable = true;
      settings = { };
    };

    xdg.configFile."niri/config.kdl".source = ./config.kdl;
  };
}
