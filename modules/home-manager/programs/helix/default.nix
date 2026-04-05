{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      pkgs.nixd
      pkgs.nixfmt
      pkgs.markdown-oxide
    ];
    settings = {
      editor = {
        line-number = "relative";
        mouse = false;
        bufferline = "multiple";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
      keys.normal = {
        esc = [
          "collapse_selection"
          "keep_primary_selection"
        ];
        ";" = "command_mode";
      };
    };
    languages = {
      language = [
        {
          name = "nix";
          formatter = {
            command = "nixfmt";
          };
          auto-format = true;
        }
      ];
    };
  };
}
