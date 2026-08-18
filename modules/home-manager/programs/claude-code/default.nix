{ inputs, pkgs, config, ... }:
let
  # Superpowers hardcodes its output path as literal text in the skill files
  # (`docs/superpowers/specs/...`, `docs/superpowers/plans/...`); there is no
  # config knob for it. Rewrite that prefix so specs land in `docs/specs/` and
  # plans in `docs/plans/`. Re-applied automatically on every Renovate bump.
  superpowers = pkgs.runCommand "superpowers-patched" { } ''
    cp -r ${inputs.superpowers} $out
    chmod -R +w $out
    grep -rl 'docs/superpowers/' $out/skills \
      | xargs -r sed -i 's#docs/superpowers/#docs/#g'
  '';
in
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
      # Auto mode: a safety classifier decides routine permission requests instead
      # of prompting per action. Falls back to normal prompting with a notice when
      # unavailable (unsupported model, org policy).
      permissions = {
        defaultMode = "auto";
      };
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
    plugins = [
      "${inputs.claude-plugins-official}/plugins/commit-commands"
      "${inputs.claude-plugins-official}/plugins/explanatory-output-style"
      "${inputs.claude-plugins-official}/plugins/feature-dev"
      "${inputs.claude-plugins-official}/plugins/frontend-design"
      "${inputs.claude-plugins-official}/plugins/code-review"
      "${inputs.claude-plugins-official}/plugins/security-guidance"
      "${inputs.claude-plugins-official}/plugins/learning-output-style"
      "${inputs.claude-plugins-official}/plugins/code-simplifier"
      superpowers
    ];
  };
}
