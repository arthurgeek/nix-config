{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
  let
    defaults = builtins.fromTOML (builtins.readFile ./defaults.toml);

    # Override default bindings (id → binding). All other hotkey IDs keep
    # the upstream defaults from defaults.toml.
    bindingOverrides = {
      "switchWorkspace.0" = "Option+Command+1";
      "switchWorkspace.1" = "Option+Command+2";
      "switchWorkspace.2" = "Option+Command+3";
      "switchWorkspace.3" = "Option+Command+4";
      "switchWorkspace.4" = "Option+Command+5";
      "switchWorkspace.5" = "Option+Command+6";
      "switchWorkspace.6" = "Option+Command+7";
      "switchWorkspace.7" = "Option+Command+8";
      "switchWorkspace.8" = "Option+Command+9";
      "moveToWorkspace.0" = "Option+Shift+Command+1";
      "moveToWorkspace.1" = "Option+Shift+Command+2";
      "moveToWorkspace.2" = "Option+Shift+Command+3";
      "moveToWorkspace.3" = "Option+Shift+Command+4";
      "moveToWorkspace.4" = "Option+Shift+Command+5";
      "moveToWorkspace.5" = "Option+Shift+Command+6";
      "moveToWorkspace.6" = "Option+Shift+Command+7";
      "moveToWorkspace.7" = "Option+Shift+Command+8";
      "moveToWorkspace.8" = "Option+Shift+Command+9";
      "workspaceBackAndForth" = "Option+Command+Tab";
      "focus.left" = "Option+Command+Left Arrow";
      "focus.down" = "Option+Command+Down Arrow";
      "focus.up" = "Option+Command+Up Arrow";
      "focus.right" = "Option+Command+Right Arrow";
      "moveWindowToWorkspaceUp" = "Option+Shift+Command+Up Arrow";
      "moveWindowToWorkspaceDown" = "Option+Shift+Command+Down Arrow";
      "move.left" = "Control+Shift+Command+Left Arrow";
      "move.down" = "Control+Shift+Command+Down Arrow";
      "move.up" = "Control+Shift+Command+Up Arrow";
      "move.right" = "Control+Shift+Command+Right Arrow";
      "cycleColumnWidthForward" = "Option+Command+.";
      "cycleColumnWidthBackward" = "Option+Command+,";
    };

    overrideHotkey =
      h: if bindingOverrides ? ${h.id} then h // { binding = bindingOverrides.${h.id}; } else h;

    settings = lib.recursiveUpdate defaults {
      borders.width = 1.5;
      focus.followsMouse = true;
      general.ipcEnabled = true;
      niri = {
        centerFocusedColumn = "always";
        singleWindowAspectRatio = "none";
      };
      statusBar = {
        showAppNames = true;
        showWorkspaceName = true;
      };
      workspaceBar.enabled = false;
      hotkeys = map overrideHotkey defaults.hotkeys;
    };
  in
  {
    xdg.configFile."omniwm/settings.toml" = {
      force = true;
      source = (pkgs.formats.toml { }).generate "omniwm-settings.toml" settings;
    };
  }
)
