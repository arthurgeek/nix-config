{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      pkgs.nixd
      pkgs.nixfmt
      pkgs.markdown-oxide
      pkgs.lldb
    ];
    settings = {
      editor = {
        line-number = "relative";
        mouse = false;
        bufferline = "multiple";
        color-modes = true;
        lsp = {
          display-inlay-hints = true;
        };
        end-of-line-diagnostics = "warning";
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "error";
        };
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
