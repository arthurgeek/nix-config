{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    preferAbbrs = true;

    functions.fish_greeting = "";

    interactiveShellInit = ''
      # FZF plugin config
      set fzf_preview_dir_cmd eza --group --git --header --group-directories-first --icons --all --oneline --color=always
      set fzf_diff_highlighter delta --features="default decorations" --paging=never
      set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"

      # OSC 133 semantic prompt marks (FinalTerm) — lets terminals like Rio
      # identify prompt/command/output boundaries for jump-to-prompt and
      # similar features.
      function __osc133_prompt_start --on-event fish_prompt
          printf '\e]133;A\e\\'
      end
      function __osc133_preexec --on-event fish_preexec
          printf '\e]133;C\e\\'
      end
      function __osc133_postexec --on-event fish_postexec
          printf '\e]133;D;%s\e\\' $status
      end

      fish_add_path ~/.cargo/bin
    '';

    shellAbbrs = {
      cat = "bat";
      glow = "glow -p";
      k = "kubectl";
      vim = "hx";
      vi = "hx";
      nvim = "hx";
    };

    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
      {
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
      }
    ];
  };
}
