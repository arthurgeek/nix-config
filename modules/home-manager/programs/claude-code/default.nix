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
      # Local document RAG (https://github.com/shinpr/mcp-local-rag). Node is
      # pinned via Nix; npx fetches+caches the package on first launch. The
      # ~80MB embedding model downloads on first use, then runs fully offline.
      local-rag = {
        command = "${pkgs.nodejs}/bin/npx";
        args = [
          "-y"
          "mcp-local-rag"
        ];
        # BASE_DIR is intentionally left unset → indexes the directory Claude
        # is launched from (per-project knowledge base).
        env = {
          # Code-specialised embeddings: ships ONNX weights transformers.js
          # loads directly, 8192-token context, trained on 30 programming
          # languages — far better for source than the prose-tuned default.
          MODEL_NAME = "jinaai/jina-embeddings-v2-base-code";
          # Codebase/API-spec preset (per upstream README): stronger keyword
          # boost so exact identifiers (useEffect, ERR_*, class names) dominate
          # ranking over fuzzy semantic hits; 0 = semantic only (def. 0.6).
          RAG_HYBRID_WEIGHT = "0.7";
          # Return only the single most-similar result group, trimming weaker
          # neighbouring matches (`related` would keep the top 2 groups).
          RAG_GROUPING = "similar";
          # Share the model cache across projects so the model downloads once
          # instead of per working directory.
          CACHE_DIR = "${config.home.homeDirectory}/.cache/mcp-local-rag/models";
        };
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
