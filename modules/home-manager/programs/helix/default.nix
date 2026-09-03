{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  helixAssistVersion = "1.0.12";
  helixAssist = pkgs.buildGoModule {
    pname = "helix-assist";
    version = helixAssistVersion;
    src = inputs.helix-assist;
    vendorHash = null;
    postPatch = ''
      substituteInPlace internal/providers/openai.go \
        --replace-fail 'Metadata     map[string]interface{} `json:"metadata,omitempty"`' \
                       'Metadata     map[string]interface{} `json:"-"`'
    '';
    subPackages = [ "cmd/helix-assist" ];
    ldflags = [
      "-s"
      "-w"
      "-X=main.Version=v${helixAssistVersion}"
    ];
    meta.mainProgram = "helix-assist";
  };

  cliProxyAPIVersion = "7.2.143";
  cliProxyAPI = pkgs.buildGoModule {
    pname = "cli-proxy-api";
    version = cliProxyAPIVersion;
    src = inputs.cli-proxy-api;
    vendorHash = "sha256-CrDp7MOr+AwJUhTovklXx3F1yaktQlvD7VYhYSY6VvY=";
    subPackages = [ "cmd/server" ];
    ldflags = [
      "-s"
      "-w"
      "-X=main.Version=v${cliProxyAPIVersion}"
      "-X=main.Commit=4b5f1eab25fca4b3815369a826e958e7c070a69e"
    ];
    postInstall = ''
      mv "$out/bin/server" "$out/bin/cli-proxy-api"
    '';
    meta.mainProgram = "cli-proxy-api";
  };

  localAPIKey = "helix-assist-local";
  proxyConfigPath = "${config.xdg.configHome}/cli-proxy-api/config.yaml";
  helixAssistWrapped = pkgs.writeShellScriptBin "helix-assist" ''
    exec ${lib.getExe helixAssist} \
      --openai-key ${localAPIKey} \
      --openai-endpoint http://127.0.0.1:8317/v1 \
      --openai-model gpt-5.4-mini \
      --openai-model-for-chat gpt-5.6-sol \
      "$@"
  '';
in
{
  home.packages = [
    cliProxyAPI
    helixAssistWrapped
  ];

  xdg.configFile."cli-proxy-api/config.yaml".text = lib.generators.toYAML { } {
    host = "127.0.0.1";
    port = 8317;
    auth-dir = "${config.xdg.dataHome}/cli-proxy-api";
    api-keys = [ localAPIKey ];
    remote-management = {
      allow-remote = false;
      secret-key = "";
      disable-control-panel = true;
    };
    plugins.enabled = false;
    logging-to-file = false;
    usage-statistics-enabled = false;
  };

  systemd.user.services.cli-proxy-api = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
    Unit.Description = "Local API bridge for Codex subscription OAuth";
    Service = {
      ExecStart = "${lib.getExe cliProxyAPI} --config ${proxyConfigPath}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };

  launchd.agents.cli-proxy-api = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        (lib.getExe cliProxyAPI)
        "--config"
        proxyConfigPath
      ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      pkgs.nixd
      pkgs.nixfmt
      pkgs.markdown-oxide
      pkgs.lldb
    ];
    settings = {
      editor = {
        line-number = "relative";
        mouse = false;
        bufferline = "multiple";
        color-modes = true;
        lsp = {
          display-inlay-hints = true;
        };
        end-of-line-diagnostics = "warning";
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "error";
        };
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
      keys.normal = {
        esc = [
          "collapse_selection"
          "keep_primary_selection"
        ];
        ";" = "command_mode";
      };
    };
    languages = {
      language-server = {
        helix-assist.command = lib.getExe helixAssistWrapped;
        rust-analyzer.config = {
          check.command = "clippy";
          cargo.features = "all";
        };
      };
      language = [
        {
          name = "nix";
          language-servers = [
            "nixd"
            "helix-assist"
          ];
          formatter = {
            command = "nixfmt";
          };
          auto-format = true;
        }
        {
          name = "rust";
          formatter = {
            command = "rustfmt";
          };
          auto-format = true;
        }
        {
          name = "haskell";
          formatter = {
            command = "ormolu";
            args = [
              "--stdin-input-file"
              "Main.hs"
            ];
          };
          auto-format = true;
        }
      ];
    };
  };
}
