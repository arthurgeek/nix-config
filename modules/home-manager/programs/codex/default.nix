{
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

  # The native Codex package intentionally has no Node dependency, while the
  # Codex Security plugin starts its local MCP server with a bare `node`.
  # Point it at Nix's exact executable without exposing Node in the user PATH.
  codexSecurity = pkgs.runCommand "codex-security" { } ''
    cp -r ${inputs.openai-plugins}/plugins/codex-security $out
    chmod -R +w $out
    substituteInPlace $out/.mcp.json \
      --replace-fail '"command": "node"' '"command": "${lib.getExe pkgs.nodejs}"'
  '';
in
{
  programs.codex = {
    enable = true;
    package = codex;

    settings = {
      model = "gpt-5.6-sol";
      model_reasoning_effort = "high";
      personality = "pragmatic";

      # Closest Codex equivalent to Claude's automatic permission mode: the
      # reviewer handles routine escalation prompts, while commands stay inside
      # a workspace-write sandbox unless an escalation is explicitly approved.
      approval_policy = "on-request";
      approvals_reviewer = "auto_review";
      sandbox_mode = "workspace-write";

      memories = {
        generate_memories = true;
        use_memories = true;
      };

      projects =
        {
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
      "${inputs.openai-plugins}/plugins/github"
    ];
  };

  # Adopt the existing hand-written config on the first activation. Its durable
  # model and project-trust settings are represented above; transient notices
  # remain Codex-owned state and do not belong in the Nix configuration.
  home.file.".codex/config.toml".force = true;
}
