{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  xdg.configFile."omniwm/settings.json" = {
    force = true;
    text = builtins.toJSON {
      borderWidth = 1.5;
      focusFollowsMouse = true;
      hotkeyBindings = [
        {
          binding = "Option+Command+1";
          id = "switchWorkspace.0";
        }
        {
          binding = "Option+Shift+Command+1";
          id = "moveToWorkspace.0";
        }
        {
          binding = "Option+Command+2";
          id = "switchWorkspace.1";
        }
        {
          binding = "Option+Shift+Command+2";
          id = "moveToWorkspace.1";
        }
        {
          binding = "Option+Command+3";
          id = "switchWorkspace.2";
        }
        {
          binding = "Option+Shift+Command+3";
          id = "moveToWorkspace.2";
        }
        {
          binding = "Option+Command+4";
          id = "switchWorkspace.3";
        }
        {
          binding = "Option+Shift+Command+4";
          id = "moveToWorkspace.3";
        }
        {
          binding = "Option+Command+5";
          id = "switchWorkspace.4";
        }
        {
          binding = "Option+Shift+Command+5";
          id = "moveToWorkspace.4";
        }
        {
          binding = "Option+Command+6";
          id = "switchWorkspace.5";
        }
        {
          binding = "Option+Shift+Command+6";
          id = "moveToWorkspace.5";
        }
        {
          binding = "Option+Command+7";
          id = "switchWorkspace.6";
        }
        {
          binding = "Option+Shift+Command+7";
          id = "moveToWorkspace.6";
        }
        {
          binding = "Option+Command+8";
          id = "switchWorkspace.7";
        }
        {
          binding = "Option+Shift+Command+8";
          id = "moveToWorkspace.7";
        }
        {
          binding = "Option+Command+9";
          id = "switchWorkspace.8";
        }
        {
          binding = "Option+Shift+Command+9";
          id = "moveToWorkspace.8";
        }
        {
          binding = "Option+Command+Tab";
          id = "workspaceBackAndForth";
        }
        {
          binding = "Option+Command+Left Arrow";
          id = "focus.left";
        }
        {
          binding = "Option+Command+Down Arrow";
          id = "focus.down";
        }
        {
          binding = "Option+Command+Up Arrow";
          id = "focus.up";
        }
        {
          binding = "Option+Command+Right Arrow";
          id = "focus.right";
        }
        {
          binding = "Option+Shift+Command+Up Arrow";
          id = "moveWindowToWorkspaceUp";
        }
        {
          binding = "Option+Shift+Command+Down Arrow";
          id = "moveWindowToWorkspaceDown";
        }
        {
          binding = "Unassigned";
          id = "moveColumnToWorkspaceUp";
        }
        {
          binding = "Unassigned";
          id = "moveColumnToWorkspaceDown";
        }
        {
          binding = "Control+Shift+Command+Left Arrow";
          id = "move.left";
        }
        {
          binding = "Control+Shift+Command+Down Arrow";
          id = "move.down";
        }
        {
          binding = "Control+Shift+Command+Up Arrow";
          id = "move.up";
        }
        {
          binding = "Control+Shift+Command+Right Arrow";
          id = "move.right";
        }
        {
          binding = "Unassigned";
          id = "focusMonitorLast";
        }
        {
          binding = "Unassigned";
          id = "focusColumnFirst";
        }
        {
          binding = "Unassigned";
          id = "focusColumnLast";
        }
        {
          binding = "Unassigned";
          id = "focusColumn.0";
        }
        {
          binding = "Unassigned";
          id = "focusColumn.1";
        }
        {
          binding = "Unassigned";
          id = "focusColumn.2";
        }
        {
          binding = "Unassigned";
          id = "focusColumn.3";
        }
        {
          binding = "Unassigned";
          id = "focusColumn.4";
        }
        {
          binding = "Unassigned";
          id = "focusColumn.5";
        }
        {
          binding = "Unassigned";
          id = "focusColumn.6";
        }
        {
          binding = "Unassigned";
          id = "focusColumn.7";
        }
        {
          binding = "Unassigned";
          id = "focusColumn.8";
        }
        {
          binding = "Option+Command+.";
          id = "cycleColumnWidthForward";
        }
        {
          binding = "Option+Command+,";
          id = "cycleColumnWidthBackward";
        }
      ];
      ipcEnabled = true;
      niriCenterFocusedColumn = "always";
      niriDefaultColumnWidth = 0.66;
      niriSingleWindowAspectRatio = "none";
      statusBarShowAppNames = true;
      statusBarShowWorkspaceName = true;
      version = 4;
      workspaceBarEnabled = false;
    };
  };
}
