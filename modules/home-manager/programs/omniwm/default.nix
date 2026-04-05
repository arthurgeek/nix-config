{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  xdg.configFile."omniwm/settings.json" = {
    force = true;
    text = builtins.toJSON {
      borderWidth = 1.5;
      focusFollowsMouse = true;
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
