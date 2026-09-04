{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  herdr = pkgs.herdr.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./immutable-plugin-registry.patch ];
  });
  plugins = import ./plugins.nix {
    inherit inputs lib pkgs;
    inherit herdr;
  };
  toml = pkgs.formats.toml { };
  automaticRenameConfig = pkgs.writeText "herdr-automatic-rename-config.sh" ''
    AGENT_TRANSCRIPT=0
  '';
  fileViewerConfig = toml.generate "herdr-file-viewer-config.toml" {
    update_check = false;
  };
  agentQuotaStateDir = "${config.xdg.stateHome}/herdr/plugins/herdr-agent-quota";
  claudeStatusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    text = ''
      input="$(mktemp)"
      trap 'rm -f "$input"' EXIT
      cat > "$input"

      export HERDR_PLUGIN_STATE_DIR=${lib.escapeShellArg agentQuotaStateDir}
      ${lib.getExe plugins.agentQuota} claude-statusline < "$input" >/dev/null 2>&1 || true

      now="''${CLAUDE_STATUSLINE_NOW:-$(date +%s)}"
      jq -Rrs --argjson now "$now" '
        def percentage:
          if type == "number" and . >= 0 and . <= 100 then round else null end;
        def bar($used):
          if $used == null then
            "----------"
          else
            ($used / 10 | round) as $filled
            | ("#" * $filled) + ("-" * (10 - $filled))
          end;
        def reset_epoch:
          if type == "number" and . >= 0 then
            floor
          elif type == "string" then
            try fromdateiso8601 catch null
          else
            null
          end;
        def eta($reset):
          ($reset | reset_epoch) as $epoch
          | if $epoch == null then
              "--"
            elif $epoch <= $now then
              "now"
            else
              ($epoch - $now | floor) as $seconds
              | if $seconds >= 86400 then
                  "\($seconds / 86400 | floor)d \(($seconds % 86400) / 3600 | floor)h"
                elif $seconds >= 3600 then
                  "\($seconds / 3600 | floor)h \(($seconds % 3600) / 60 | floor)m"
                else
                  "\($seconds / 60 | floor)m"
                end
            end;

        (try fromjson catch {} | if type == "object" then . else {} end) as $root
        | ($root.model.display_name
            | if type == "string" and length > 0 then . else null end) as $model
        | ($root.context_window.used_percentage | percentage) as $context
        | ($root.rate_limits.five_hour.used_percentage | percentage) as $five_hour
        | ($root.rate_limits.seven_day.used_percentage | percentage) as $weekly
        | ($root.rate_limits.five_hour.resets_at) as $five_hour_reset
        | ($root.rate_limits.seven_day.resets_at) as $weekly_reset
        | [
            "\u001b[1;36mModel:\u001b[0m \($model // "--") | \u001b[1;36mContext used:\u001b[0m \(if $context == null then "--" else "\($context)%" end)",
            "\u001b[1;35m5h:\u001b[0m [\u001b[32m\(bar($five_hour))\u001b[0m] Used: \(if $five_hour == null then "--" else "\($five_hour)%" end) | Reset: \(eta($five_hour_reset))",
            "\u001b[1;34mWeekly:\u001b[0m [\u001b[32m\(bar($weekly))\u001b[0m] Used: \(if $weekly == null then "--" else "\($weekly)%" end) | Reset: \(eta($weekly_reset))"
          ]
        | .[]
      ' "$input"
    '';
  };

  colors = {
    text = "#cad3f5";
    muted = "#a5adcb";
    green = "#a6da95";
    yellow = "#eed49f";
    red = "#ed8796";
  };
  token = name: color: {
    token = name;
    fg = color;
    bold = false;
    dim = false;
  };
  windowTokens = name: [
    (token "${"$"}${name}_normal" colors.green)
    (token "${"$"}${name}_warning" colors.yellow)
    (token "${"$"}${name}_danger" colors.red)
    (token "${"$"}${name}_unknown" colors.muted)
  ];
in

{
  xdg.configFile = {
    "herdr/plugins.json" = {
      source = plugins.registry;
      force = true;
    };
    "herdr-automatic-rename/config.sh".source = automaticRenameConfig;
    "herdr/plugins/config/herdr-file-viewer/config.toml".source = fileViewerConfig;
  };

  programs.fish.interactiveShellInit = lib.mkAfter ''
    source ${plugins.automaticRename}/shell/hook.fish
  '';

  programs.claude-code.settings.statusLine = {
    type = "command";
    command = "HERDR_PLUGIN_STATE_DIR=${lib.escapeShellArg agentQuotaStateDir} ${lib.escapeShellArg (lib.getExe claudeStatusline)}";
    refreshInterval = 60;
  };

  programs.herdr = {
    enable = true;
    package = herdr;

    settings = {
      onboarding = false;

      theme = {
        name = "catppuccin";
        auto_switch = true;
        dark_name = "catppuccin";
        light_name = "catppuccin-latte";
      };

      terminal = {
        default_shell = lib.getExe pkgs.fish;
        shell_mode = "auto";
        new_cwd = "follow";
      };

      update = {
        channel = "stable";
        version_check = false;
        manifest_check = false;
      };

      ui = {
        agent_panel_sort = "priority";
        confirm_close = true;
        prompt_new_tab_name = false;
        show_agent_labels_on_pane_borders = true;
        toast = {
          delivery = "herdr";
          herdr.position = "bottom-right";
        };
        sidebar.agents = {
          row_gap = 1;
          rows = [
            [
              "state_icon"
              {
                token = "tab";
                fg = colors.text;
                bold = true;
                dim = false;
              }
              {
                token = "$quota_provider_model";
                bold = true;
                dim = false;
              }
            ]
            [ (token "$quota_topic" colors.text) ]
            [
              (token "$quota_cache" colors.muted)
              (token "$quota_cache_ttl" colors.muted)
              (token "$quota_cache_state" colors.yellow)
              (token "$quota_error" colors.yellow)
            ]
            ([ (token "$quota_context" colors.muted) ] ++ windowTokens "quota_week_inline")
            (windowTokens "quota_5h" ++ windowTokens "quota_week")
          ];
        };
      };

      session.resume_agents_on_restore = true;

      keys = {
        prefix = "ctrl+b";
        command = [
          {
            key = "prefix+alt+g";
            type = "popup";
            command = lib.getExe pkgs.lazygit;
            width = "90%";
            height = "90%";
          }
          {
            key = "prefix+alt+j";
            type = "popup";
            command = lib.getExe pkgs.lazyjj;
            width = "90%";
            height = "90%";
          }
          {
            key = "prefix+alt+f";
            type = "popup";
            command = lib.getExe pkgs.jj-fzf;
            width = "90%";
            height = "90%";
          }
          {
            key = "prefix+k";
            type = "plugin_action";
            command = "herdr-bar.open";
            description = "Open Herdr bar";
          }
          {
            key = "prefix+p";
            type = "plugin_action";
            command = "jt.command-palette.open";
            description = "Open plugin command palette";
          }
          {
            key = "prefix+f";
            type = "plugin_action";
            command = "herdr-file-viewer.open-file-viewer";
            description = "Open file viewer";
          }
          {
            key = "prefix+shift+f";
            type = "plugin_action";
            command = "herdr-file-viewer.open-file-viewer-tab";
            description = "Open file viewer in a tab";
          }
          {
            key = "prefix+shift+r";
            type = "plugin_action";
            command = "herdr-agent-quota.refresh";
            description = "Refresh agent quotas";
          }
        ];
      };
    };
  };
}
