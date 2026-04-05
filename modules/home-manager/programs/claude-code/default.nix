{ inputs, pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    settings = {
      theme = "dark";
      includeCoAuthoredBy = false;
      gitAttribution = false;
    };
    mcpServers = {
      serena = {
        command = "${inputs.serena.packages.${pkgs.stdenv.hostPlatform.system}.serena}/bin/serena";
        args = [ "start-mcp-server" ];
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
