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
    # Attribute set, not a list: with a list, home-manager derives each plugin's
    # directory name from the path's base name. That is stable for the official
    # plugins but not for `superpowers`, which is a derivation whose base name
    # (`<hash>-superpowers-patched`) changes on every bump. Naming them keeps the
    # on-disk plugin directories stable and readable.
    plugins = {
      commit-commands = "${inputs.claude-plugins-official}/plugins/commit-commands";
      feature-dev = "${inputs.claude-plugins-official}/plugins/feature-dev";
      frontend-design = "${inputs.claude-plugins-official}/plugins/frontend-design";
      code-review = "${inputs.claude-plugins-official}/plugins/code-review";
      security-guidance = "${inputs.claude-plugins-official}/plugins/security-guidance";
      learning-output-style = "${inputs.claude-plugins-official}/plugins/learning-output-style";
      inherit superpowers;
    };
  };
}
