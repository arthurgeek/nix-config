{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # Superpowers ships an OpenCode-native plugin that injects its bootstrap and
  # registers its skills. Keep its plan/spec paths consistent with Claude and
  # Codex in this configuration.
  superpowers = pkgs.runCommand "superpowers" { } ''
    cp -r ${inputs.superpowers} $out
    chmod -R +w $out
    grep -rl 'docs/superpowers/' $out/skills \
      | xargs -r sed -i 's#docs/superpowers/#docs/#g'
  '';

  pluginSkills =
    plugin: names:
    lib.genAttrs names (name: "${inputs.openai-plugins}/plugins/${plugin}/skills/${name}");
in
{
  programs.opencode = {
    enable = true;

    settings = {
      model = "openai/gpt-5.6-sol";
      autoupdate = false;
      share = "disabled";

      provider.openai.models."gpt-5.6-sol".options = {
        reasoningEffort = "high";
        reasoningSummary = "auto";
        textVerbosity = "low";
        include = [ "reasoning.encrypted_content" ];
      };

      # OpenCode defaults to allowing routine work. Preserve that flow while
      # prompting before destructive or externally visible shell operations.
      permission = {
        external_directory = "ask";
        doom_loop = "ask";
        bash = {
          "*" = "allow";
          "rm *" = lib.hm.dag.entryAfter [ "*" ] "ask";
          "sudo *" = lib.hm.dag.entryAfter [ "*" ] "ask";
          "git clean *" = lib.hm.dag.entryAfter [ "*" ] "ask";
          "git reset *" = lib.hm.dag.entryAfter [ "*" ] "ask";
          "git commit" = lib.hm.dag.entryAfter [ "*" ] "ask";
          "git commit *" = lib.hm.dag.entryAfter [ "*" ] "ask";
          "git push" = lib.hm.dag.entryAfter [ "*" ] "ask";
          "git push *" = lib.hm.dag.entryAfter [ "*" ] "ask";
        };
      };

      plugin = [ superpowers ];

      mcp.codex-security = {
        type = "local";
        command = [
          (lib.getExe pkgs.nodejs)
          "${inputs.openai-plugins}/plugins/codex-security/mcp/server.mjs"
          "--stdio"
        ];
        enabled = true;
        timeout = 900000;
      };
    };

    # OpenCode consumes Codex plugin skills directly. Superpowers is omitted
    # here because its native plugin above registers those skills itself.
    skills =
      pluginSkills "build-web-apps" [
        "frontend-app-builder"
        "frontend-testing-debugging"
        "react-best-practices"
        "shadcn-best-practices"
        "stripe-best-practices"
        "supabase-best-practices"
      ]
      // pluginSkills "codex-security" [
        "attack-path-analysis"
        "deep-security-scan"
        "finding-discovery"
        "fix-finding"
        "propose-security-hardening"
        "security-diff-scan"
        "security-scan"
        "threat-model"
        "track-findings"
        "triage-finding"
        "validation"
        "vulnerability-writeup"
      ]
      // pluginSkills "github" [
        "gh-address-comments"
        "gh-fix-ci"
        "github"
        "yeet"
      ];

    context = ''
      # OpenCode-specific integrations

      GitHub connector and GitHub MCP tools are intentionally unavailable.
      When a GitHub workflow skill mentions them, use the authenticated `gh`
      CLI for GitHub reads and writes instead.
    '';
  };
}
