{
  herdr,
  inputs,
  lib,
  pkgs,
}:
let
  toml = pkgs.formats.toml { };
  manifest = name: value: toml.generate "${name}-manifest.toml" value;

  herdrBarManifest = manifest "herdr-bar" {
    id = "herdr-bar";
    name = "Bar";
    version = "0.3.0";
    min_herdr_version = "0.7.4";
    description = "Cmd+K command bar: fuzzy-jump to any tab, pane, or agent";
    platforms = [
      "linux"
      "macos"
    ];
    actions = [
      {
        id = "open";
        title = "Open bar";
        description = "Fuzzy-jump to any tab, pane, or agent";
        contexts = [ "global" ];
        command = [
          (lib.getExe herdr)
          "plugin"
          "pane"
          "open"
          "--plugin"
          "herdr-bar"
          "--entrypoint"
          "bar"
          "--placement"
          "popup"
        ];
      }
    ];
    panes = [
      {
        id = "bar";
        title = "Bar";
        description = "Fuzzy-jump to any tab, pane, or agent";
        placement = "popup";
        width = "74%";
        height = "62%";
        command = [ "./run.py" ];
      }
    ];
  };

  herdrBar = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr-bar";
    version = "0.3.0";
    src = inputs.herdr-bar;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/src"
      install -Dm755 run.py "$out/run.py"
      cp -R src/herdr_bar "$out/src/herdr_bar"
      install -Dm444 ${herdrBarManifest} "$out/herdr-plugin.toml"

      substituteInPlace "$out/run.py" \
        --replace-fail '#!/usr/bin/env python3' '#!${lib.getExe pkgs.python3}'
      substituteInPlace "$out/src/herdr_bar/age.py" \
        --replace-fail '["ps",' '["${pkgs.unixtools.ps}/bin/ps",'
      wrapProgram "$out/run.py" \
        --prefix PATH : ${lib.makeBinPath [ herdr ]}

      runHook postInstall
    '';
  };

  commandPaletteManifest = manifest "herdr-command-palette" {
    id = "jt.command-palette";
    name = "Command Palette (fzf)";
    version = "0.1.0";
    min_herdr_version = "0.7.0";
    description = "An fzf command palette for every registered Herdr plugin action.";
    platforms = [
      "linux"
      "macos"
    ];
    actions = [
      {
        id = "open";
        title = "Command palette (all plugin actions)";
        contexts = [ "workspace" ];
        command = [ "./open.sh" ];
      }
    ];
    panes = [
      {
        id = "palette";
        title = "Command palette";
        placement = "overlay";
        command = [
          (lib.getExe pkgs.bash)
          "-c"
          ''exec "$HERDR_PLUGIN_ROOT/palette.sh"''
        ];
      }
    ];
  };

  commandPalette = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr-command-palette";
    version = "0.1.0";
    src = inputs.herdr-command-palette;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 open.sh "$out/open.sh"
      install -Dm755 palette.sh "$out/palette.sh"
      install -Dm444 ${commandPaletteManifest} "$out/herdr-plugin.toml"
      patchShebangs "$out/open.sh" "$out/palette.sh"

      wrapProgram "$out/open.sh" \
        --prefix PATH : ${
          lib.makeBinPath [
            herdr
            pkgs.jq
          ]
        }
      wrapProgram "$out/palette.sh" \
        --prefix PATH : ${
          lib.makeBinPath [
            herdr
            pkgs.coreutils
            pkgs.fzf
            pkgs.jq
          ]
        }

      runHook postInstall
    '';
  };

  automaticRenameEvents = [
    "workspace.created"
    "workspace.closed"
    "workspace.renamed"
    "workspace.moved"
    "workspace.reordered"
    "worktree.created"
    "worktree.opened"
    "worktree.removed"
    "tab.created"
    "tab.closed"
    "tab.renamed"
    "tab.moved"
    "tab.focused"
    "pane.focused"
    "pane.agent_detected"
    "pane.agent_status_changed"
    "pane.closed"
    "pane.exited"
    "pane.moved"
    "pane.created"
  ];
  automaticRenameManifest = manifest "herdr-automatic-rename" {
    id = "herdr-automatic-rename";
    name = "Herdr Automatic Rename";
    version = "0.8.0";
    min_herdr_version = "0.7.1";
    description = "Automatically name Herdr tabs from their context and foreground process.";
    platforms = [
      "linux"
      "macos"
    ];
    startup = [
      {
        command = [
          "./automatic-rename.sh"
          "startup"
        ];
      }
    ];
    events = map (event: {
      on = event;
      command = [
        "./automatic-rename.sh"
        event
      ];
    }) automaticRenameEvents;
    actions = [
      {
        id = "reset";
        title = "Reset tab to automatic naming";
        contexts = [ "global" ];
        command = [
          "./automatic-rename.sh"
          "reset"
        ];
      }
    ];
  };

  automaticRename = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr-automatic-rename";
    version = "0.8.0";
    src = inputs.herdr-automatic-rename;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/shell"
      install -Dm755 automatic-rename.sh "$out/automatic-rename.sh"
      install -Dm444 naming.sh icons.sh git.sh transcript.sh "$out/"
      install -Dm444 shell/hook.bash shell/hook.zsh shell/hook.fish "$out/shell/"
      install -Dm444 ${automaticRenameManifest} "$out/herdr-plugin.toml"
      patchShebangs "$out/automatic-rename.sh"
      wrapProgram "$out/automatic-rename.sh" \
        --prefix PATH : ${
          lib.makeBinPath [
            herdr
            pkgs.bash
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.gnused
            pkgs.jq
          ]
        }

      runHook postInstall
    '';
  };

  fileViewerManifest = manifest "herdr-file-viewer" {
    id = "herdr-file-viewer";
    name = "herdr-file-viewer";
    version = "1.16.0";
    min_herdr_version = "0.7.0";
    description = "A git-aware, read-only file viewer in a Herdr pane.";
    platforms = [
      "linux"
      "macos"
    ];
    panes = [
      {
        id = "file-viewer";
        title = "Files";
        placement = "split";
        command = [ "./bin/herdr-file-viewer" ];
      }
    ];
    actions = [
      {
        id = "open-file-viewer";
        title = "Open file viewer";
        description = "Open the git-aware file viewer in a split pane beside the current work.";
        platforms = [
          "linux"
          "macos"
        ];
        command = [ "./scripts/open-file-viewer.sh" ];
      }
      {
        id = "open-file-viewer-tab";
        title = "Open file viewer (tab)";
        description = "Open the git-aware file viewer in its own tab.";
        platforms = [
          "linux"
          "macos"
        ];
        command = [ "./scripts/open-file-viewer-tab.sh" ];
      }
    ];
  };

  fileViewer = pkgs.rustPlatform.buildRustPackage {
    pname = "herdr-file-viewer";
    version = "1.16.0";
    src = inputs.herdr-file-viewer;
    cargoLock.lockFile = "${inputs.herdr-file-viewer}/Cargo.lock";
    cargoBuildFlags = [
      "--bin"
      "herdr-file-viewer"
    ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    nativeCheckInputs = [ pkgs.git ];

    postInstall = ''
      mkdir -p "$out/assets" "$out/scripts"
      install -Dm444 assets/markdown-style.json "$out/assets/markdown-style.json"
      install -Dm755 scripts/open-file-viewer.sh "$out/scripts/open-file-viewer.sh"
      install -Dm755 scripts/open-file-viewer-tab.sh "$out/scripts/open-file-viewer-tab.sh"
      install -Dm444 ${fileViewerManifest} "$out/herdr-plugin.toml"

      substituteInPlace "$out/scripts/open-file-viewer.sh" \
        --replace-fail 'viewer_bin="$script_dir/../target/release/herdr-file-viewer"' \
                       "viewer_bin=\"$out/bin/herdr-file-viewer\""
      substituteInPlace "$out/scripts/open-file-viewer-tab.sh" \
        --replace-fail 'viewer_bin="$script_dir/../target/release/herdr-file-viewer"' \
                       "viewer_bin=\"$out/bin/herdr-file-viewer\""
      patchShebangs "$out/scripts/open-file-viewer.sh" "$out/scripts/open-file-viewer-tab.sh"
      wrapProgram "$out/scripts/open-file-viewer.sh" \
        --prefix PATH : ${
          lib.makeBinPath [
            herdr
            pkgs.coreutils
          ]
        }
      wrapProgram "$out/scripts/open-file-viewer-tab.sh" \
        --prefix PATH : ${
          lib.makeBinPath [
            herdr
            pkgs.coreutils
          ]
        }
    '';

    postFixup = ''
      wrapProgram "$out/bin/herdr-file-viewer" \
        --prefix PATH : ${
          lib.makeBinPath (
            [
              pkgs.bat
              pkgs.delta
              pkgs.git
              pkgs.glow
            ]
            ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.xdg-utils ]
          )
        }
    '';
  };

  agentQuotaManifest = manifest "herdr-agent-quota" {
    id = "herdr-agent-quota";
    name = "Herdr Agent Quota";
    version = "1.3.0";
    min_herdr_version = "0.8.0";
    description = "Credential-scoped AI quota and context for supported agent CLIs.";
    platforms = [
      "linux"
      "macos"
    ];
    startup = [
      {
        command = [
          "./bin/herdr-agent-quota"
          "refresh"
          "--provider"
          "all"
        ];
      }
    ];
    actions = [
      {
        id = "refresh";
        title = "Refresh agent quota";
        command = [
          "./bin/herdr-agent-quota"
          "refresh"
          "--provider"
          "all"
          "--force"
        ];
      }
    ];
    events = [
      {
        id = "agent-quota-refresh";
        on = "pane.agent_detected";
        command = [
          "./bin/herdr-agent-quota"
          "event"
        ];
      }
      {
        id = "agent-quota-status-refresh";
        on = "pane.agent_status_changed";
        command = [
          "./bin/herdr-agent-quota"
          "event"
        ];
      }
      {
        id = "focused-agent-quota-refresh";
        on = "pane.focused";
        command = [
          "./bin/herdr-agent-quota"
          "focus"
        ];
      }
    ];
    panes = [
      {
        id = "dashboard";
        title = "Agent quota";
        placement = "popup";
        command = [
          "./bin/herdr-agent-quota"
          "dashboard"
        ];
      }
    ];
  };

  agentQuota = pkgs.rustPlatform.buildRustPackage {
    pname = "herdr-agent-quota";
    version = "1.3.0";
    src = inputs.herdr-agent-quota;
    cargoLock.lockFile = "${inputs.herdr-agent-quota}/Cargo.lock";
    nativeBuildInputs = [ pkgs.makeWrapper ];
    nativeCheckInputs = [ pkgs.perl ];

    postInstall = ''
      install -Dm444 ${agentQuotaManifest} "$out/herdr-plugin.toml"
    '';

    postFixup = ''
      wrapProgram "$out/bin/herdr-agent-quota" \
        --prefix PATH : ${lib.makeBinPath [ herdr ]}
    '';

    meta.mainProgram = "herdr-agent-quota";
  };

  roots = [
    {
      id = "herdr-bar";
      package = herdrBar;
    }
    {
      id = "jt.command-palette";
      package = commandPalette;
    }
    {
      id = "herdr-automatic-rename";
      package = automaticRename;
    }
    {
      id = "herdr-file-viewer";
      package = fileViewer;
    }
    {
      id = "herdr-agent-quota";
      package = agentQuota;
    }
  ];

  registry = pkgs.runCommand "herdr-plugins.json" { nativeBuildInputs = [ herdr ]; } ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$TMPDIR/config"
    export XDG_STATE_HOME="$TMPDIR/state"
    mkdir -p "$HOME" "$XDG_CONFIG_HOME/herdr" "$XDG_STATE_HOME"

    ${lib.concatMapStringsSep "\n" (plugin: ''
      ${lib.getExe herdr} plugin link ${plugin.package} --enabled >/dev/null
    '') roots}

    install -Dm444 "$XDG_CONFIG_HOME/herdr/plugins.json" "$out"
  '';
in
{
  inherit
    agentQuota
    automaticRename
    commandPalette
    fileViewer
    herdrBar
    registry
    roots
    ;
}
