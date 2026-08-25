{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  pi = pkgs.pi-coding-agent;
  json = pkgs.formats.json { };

  # Keep plan/spec paths consistent across every configured coding agent.
  superpowers = pkgs.runCommand "superpowers" { } ''
    cp -r ${inputs.superpowers} $out
    chmod -R +w $out
    grep -rl 'docs/superpowers/' $out/skills \
      | xargs -r sed -i 's#docs/superpowers/#docs/#g'
  '';

  gondolinExtension = pkgs.buildNpmPackage {
    pname = "pi-extension-gondolin";
    inherit (pi) version;
    src = "${pi.src}/packages/coding-agent/examples/extensions/gondolin";
    npmDepsHash = "sha256-iOXDL298/OAWRNTO9fy4FjRFbUejakq7sB4JhIyLejM=";
    npmInstallFlags = [
      "--ignore-scripts"
      "--omit=optional"
    ];
    dontNpmBuild = true;
    patches = [ ./gondolin-hardening.patch ];

    postPatch = ''
      substituteInPlace index.ts \
        --replace-fail '@superpowers@' '${superpowers}' \
        --replace-fail '@openaiPlugins@' '${inputs.openai-plugins}'
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r index.ts package.json package-lock.json node_modules $out/
      runHook postInstall
    '';
  };

  guestArchitecture =
    if pkgs.stdenv.hostPlatform.isAarch64 then
      "aarch64"
    else if pkgs.stdenv.hostPlatform.isx86_64 then
      "x86_64"
    else
      throw "Pi's Gondolin image is unavailable for ${pkgs.stdenv.hostPlatform.system}";
  guestImageVersion = "0.2.0";
  guestImageArchive = pkgs.fetchurl {
    url = "https://github.com/earendil-works/gondolin/releases/download/image-alpine-base--${guestImageVersion}/gondolin-image-alpine-base-${guestImageVersion}-${guestArchitecture}.tar.gz";
    hash =
      {
        aarch64 = "sha256-FT9JlECcJQ74DuXIyhvhlFkf6a3y7OHChGAny8GIvf0=";
        x86_64 = "sha256-7jBU8blIxIGzXTpaT/nrPbZ+ouH9tRWdhp/uXt4IW6s=";
      }
      .${guestArchitecture};
  };
  gondolinGuest =
    pkgs.runCommand "gondolin-alpine-base-${guestImageVersion}-${guestArchitecture}"
      {
        nativeBuildInputs = [
          pkgs.gnutar
          pkgs.gzip
        ];
      }
      ''
        mkdir -p $out
        tar --extract --gzip --file=${guestImageArchive} --directory=$out
      '';

  # Sandboxing is the default. pi-host is the explicit escape hatch for trusted
  # work that needs host credentials, tools, or extension-provided operations.
  piWrapped =
    pkgs.runCommand "pi-sandboxed-${pi.version}"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
        meta.mainProgram = "pi";
      }
      ''
        mkdir -p $out/bin
        makeWrapper ${lib.getExe pi} $out/bin/pi \
          --prefix PATH : ${lib.makeBinPath [ pkgs.qemu ]} \
          --set-default GONDOLIN_GUEST_DIR ${gondolinGuest} \
          --set-default GONDOLIN_VMM qemu \
          --add-flags '-e' \
          --add-flags ${gondolinExtension}
        makeWrapper ${lib.getExe pi} $out/bin/pi-host
      '';

  pluginSkills =
    plugin: names: map (name: "${inputs.openai-plugins}/plugins/${plugin}/skills/${name}") names;
  githubSkills = map (name: "${inputs.openai-skills}/skills/.curated/${name}") [
    "gh-address-comments"
    "gh-fix-ci"
    "yeet"
  ];
in
{
  home.packages = [ piWrapped ];

  home.file.".pi/agent/settings.json" = {
    force = true;
    source = json.generate "pi-settings.json" {
      defaultProvider = "openai";
      defaultModel = "gpt-5.6-sol";
      defaultThinkingLevel = "high";
      defaultProjectTrust = "ask";
      theme = "dark";
      enableInstallTelemetry = false;
      enableAnalytics = false;
      enableSkillCommands = true;
      lastChangelogVersion = pi.version;
      packages = [ superpowers ];
      skills =
        pluginSkills "build-web-apps" [
          "frontend-app-builder"
          "frontend-testing-debugging"
          "react-best-practices"
          "shadcn-best-practices"
          "stripe-best-practices"
          "supabase-best-practices"
        ]
        ++ githubSkills;
    };
  };

  home.file.".pi/agent/AGENTS.md" = {
    force = true;
    text = ''
      # Pi-specific execution

      When the system prompt reports `/workspace` as the working directory,
      `pi` is routing built-in file and shell tools, plus `!` commands, through
      a Gondolin micro-VM. The startup directory is mounted read-write, skill
      roots are mounted read-only through their Nix store permissions, host
      environment secrets are removed from shell commands, and guest networking
      is disabled. Pi itself and tools provided by other extensions still run on
      the host; do not treat them as sandboxed.

      When the system prompt instead reports a host path, the session was
      started with `pi-host` and built-in tools are not sandboxed. If sandboxed
      work requires host-only tools, credentials, or network access, explain the
      limitation and ask the user to restart with `pi-host`. Do not attempt to
      escape the VM.

      GitHub connector and MCP tools are intentionally unavailable. When a
      GitHub workflow skill mentions them, use authenticated `gh` in a
      `pi-host` session instead.
    '';
  };
}
