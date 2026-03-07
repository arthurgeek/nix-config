{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      set -gx fish_greeting
      set -gx EDITOR nvim
      set -gx TERM wezterm
      set -gx ANSIBLE_FORCE_COLOR true
    '';

    interactiveShellInit = ''
      # EZA (formerly exa) config
      set EXA_STANDARD_OPTIONS --group --git --header --group-directories-first --icons
      set EXA_L_OPTIONS $EXA_STANDARD_OPTIONS
      set EXA_LT_OPTIONS --long --tree --level

      # FZF plugin config
      set fzf_preview_dir_cmd eza $EXA_STANDARD_OPTIONS --all --oneline --color=always
      set fzf_diff_highlighter delta --features="default decorations" --paging=never
      set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"

    '';

    shellAbbrs = {
      cat = "bat";
      k = "kubectl";
      vim = "nvim";
      vi = "nvim";
      ls = "eza";
      vimdiff = "nvim -d";
    };

    plugins = [
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "colored-man-pages"; src = pkgs.fishPlugins.colored-man-pages.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
      { name = "puffer"; src = pkgs.fishPlugins.puffer.src; }
      { name = "forgit"; src = pkgs.fishPlugins.forgit.src; }
    ];
  };
}
