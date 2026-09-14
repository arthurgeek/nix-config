{
  config,
  inputs,
  lib,
  pkgs,
  userConfig,
  ...
}:
let
  # codex-cli-nix's package recipe still reads the deprecated
  # `stdenv.isLinux`. Supply the equivalent modern platform value until the
  # upstream package adopts `stdenv.hostPlatform.isLinux`.
  codex = pkgs.callPackage "${inputs.codex-cli-nix}/package.nix" {
    runtime = "native";
    stdenv = pkgs.stdenv // {
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
    };
  };

  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/Users/${userConfig.name}"
    else
      "/home/${userConfig.name}";

  # Keep this identical to the Claude module: Superpowers hardcodes
  # `docs/superpowers/`, while this configuration keeps plans and specs directly
  # under `docs/`. The derivation name must match the Codex plugin manifest.
  superpowers = pkgs.runCommand "superpowers" { } ''
    cp -r ${inputs.superpowers} $out
    chmod -R +w $out
    grep -rl 'docs/superpowers/' $out/skills \
      | xargs -r sed -i 's#docs/superpowers/#docs/#g'
  '';

  # The native Codex package intentionally has no Node dependency. Wrap the
  # Codex Security launcher with Nix's exact executable without exposing Node
  # in the user PATH.
  codexSecurity = pkgs.runCommand "codex-security" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    cp -r ${inputs.openai-plugins}/plugins/codex-security $out
    chmod -R +w $out
    wrapProgram $out/scripts/launch_codex_security_mcp \
      --set CODEX_MCP_NODE_PATH ${lib.getExe pkgs.nodejs}
  '';

  openaiDocs = pkgs.runCommand "openai-docs" { } ''
    cp -r ${inputs.openai-skills}/skills/.curated/openai-docs $out
    chmod -R +w $out
    substituteInPlace $out/SKILL.md \
      --replace-fail 'node <skill-dir>/scripts/' '${lib.getExe pkgs.nodejs} <skill-dir>/scripts/' \
      --replace-fail 'node scripts/resolve-latest-model-info.js' '${lib.getExe pkgs.nodejs} scripts/resolve-latest-model-info.js'
  '';

  ghAddressComments = pkgs.runCommand "gh-address-comments" { } ''
    cp -r ${inputs.openai-skills}/skills/.curated/gh-address-comments $out
    chmod -R +w $out
    substituteInPlace $out/scripts/fetch_comments.py \
      --replace-fail '#!/usr/bin/env python3' '#!${lib.getExe pkgs.python3}'
    substituteInPlace $out/SKILL.md \
      --replace-fail 'Run scripts/fetch_comments.py' 'Run ${lib.getExe pkgs.python3} <path-to-skill>/scripts/fetch_comments.py'
  '';

  ghFixCi = pkgs.runCommand "gh-fix-ci" { } ''
    cp -r ${inputs.openai-skills}/skills/.curated/gh-fix-ci $out
    chmod -R +w $out
    substituteInPlace $out/scripts/inspect_pr_checks.py \
      --replace-fail '#!/usr/bin/env python3' '#!${lib.getExe pkgs.python3}'
    substituteInPlace $out/SKILL.md \
      --replace-fail 'python "' '${lib.getExe pkgs.python3} "'
  '';

  curatedSkills = {
    openai-docs = openaiDocs;
    define-goal = "${inputs.openai-skills}/skills/.curated/define-goal";
    gh-address-comments = ghAddressComments;
    gh-fix-ci = ghFixCi;
    yeet = "${inputs.openai-skills}/skills/.curated/yeet";
  };

  codexConfig = config.home.file.".codex/config.toml".source;
in
{
  programs.codex = {
    enable = true;
    package =
      assert lib.versionAtLeast codex.version "0.150.1";
      codex;

    settings = {
      model = "gpt-6-astra";
      model_reasoning_effort = "high";
      personality = "pragmatic";
      tui = {
        status_line = [
          "model"
          "context-used"
          "five-hour-limit"
          "weekly-limit"
        ];
        status_line_use_colors = true;
        vim_mode_default = true;
      };

      # Closest Codex equivalent to Claude's automatic permission mode: the
      # reviewer handles routine escalation prompts, while commands stay inside
      # a workspace-write sandbox unless an escalation is explicitly approved.
      approval_policy = "on-request";
      approvals_reviewer = "guardian_subagent";
      sandbox_mode = "workspace-write";

      memories = {
        generate_memories = true;
        use_memories = true;
      };

      projects = {
        "${homeDirectory}/nix-config".trust_level = "trusted";
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        "${homeDirectory}/Development/zig/kova".trust_level = "trusted";
        "${homeDirectory}/Development/rust/hive".trust_level = "trusted";
        "${homeDirectory}/Development/c/nilo".trust_level = "trusted";
        "${homeDirectory}/Development/ocaml/hale".trust_level = "trusted";
        "${homeDirectory}/Development/zig/linea".trust_level = "trusted";
      };
    };

    # Native Codex counterparts for the Claude development, frontend, review,
    # security, and commit/PR workflows. Plugins bring their own skills and are
    # installed into Home Manager's local Codex marketplace.
    plugins = [
      superpowers
      "${inputs.openai-plugins}/plugins/build-web-apps"
      codexSecurity
    ];

    skills = curatedSkills;
  };

  # Codex persists hook trust through config/batchWrite, so its config cannot be
  # a read-only store symlink. Keep declarative settings authoritative while
  # carrying Codex-owned hook hashes across activations.
  home.file.".codex/config.toml" = {
    enable = false;
    force = true;
  };

  home.activation.codexMutableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config="$HOME/.codex/config.toml"
    workdir="$(${pkgs.coreutils}/bin/mktemp -d)"
    trap '${pkgs.coreutils}/bin/rm -rf "$workdir"' EXIT

    ${pkgs.coreutils}/bin/cp ${codexConfig} "$workdir/config.toml"
    ${pkgs.coreutils}/bin/chmod u+w "$workdir/config.toml"
    if [ -f "$config" ] && [ ! -L "$config" ]; then
      in_hook_state=0
      while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
          '[hooks.state]'|'[hooks.state.'*) in_hook_state=1 ;;
          '['*) in_hook_state=0 ;;
        esac
        if [ "$in_hook_state" -eq 1 ]; then
          printf '%s\n' "$line" >> "$workdir/hook-state.toml"
        fi
      done < "$config"

      if [ -s "$workdir/hook-state.toml" ]; then
        printf '\n' >> "$workdir/config.toml"
        ${pkgs.coreutils}/bin/cat "$workdir/hook-state.toml" >> "$workdir/config.toml"
      fi
    fi

    run ${pkgs.coreutils}/bin/mkdir -p "$HOME/.codex"
    run ${pkgs.coreutils}/bin/rm -f "$config"
    run ${pkgs.coreutils}/bin/install -m600 "$workdir/config.toml" "$config"
  '';
}
