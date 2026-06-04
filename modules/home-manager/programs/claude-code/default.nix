{ inputs, pkgs, ... }:
{
  home.file.".claude/hooks/auto-approve-readonly.sh" = {
    source = ./hooks/auto-approve-readonly.sh;
    executable = true;
  };

  programs.claude-code = {
    enable = true;
    package = inputs.nix-claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      theme = "dark";
      includeCoAuthoredBy = false;
      gitAttribution = false;
      autoMemoryEnabled = true;
      autoDreamEnabled = true;
      hooks = {
        PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "~/.claude/hooks/auto-approve-readonly.sh";
              }
            ];
          }
        ];
      };
    };
    mcpServers = {
      serena = {
        command = "${inputs.serena.packages.${pkgs.stdenv.hostPlatform.system}.serena}/bin/serena";
        args = [
          "start-mcp-server"
          "--open-web-dashboard=False"
        ];
      };
    };
    plugins = [
      "${inputs.claude-plugins-official}/plugins/commit-commands"
      "${inputs.claude-plugins-official}/plugins/explanatory-output-style"
      "${inputs.claude-plugins-official}/plugins/feature-dev"
      "${inputs.claude-plugins-official}/plugins/frontend-design"
      "${inputs.claude-plugins-official}/plugins/code-review"
      "${inputs.claude-plugins-official}/plugins/security-guidance"
      "${inputs.claude-plugins-official}/plugins/learning-output-style"
      "${inputs.claude-plugins-official}/plugins/code-simplifier"
      inputs.superpowers
    ];
  };
}
