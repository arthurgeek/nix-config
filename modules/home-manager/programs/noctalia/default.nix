{ inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Colours, fonts, popup opacity and the wallpaper come from stylix's noctalia
  # target. Only what differs from noctalia's defaults is set here.
  programs.noctalia = {
    enable = true;
    # Launched from niri's spawn-at-startup instead of systemd. Its unit is
    # bound to the wayland session target with no per-service override, so as
    # a systemd service it would also start under the Hyprland session.
    systemd.enable = false;
    settings = {
      shell = {
        animation.enabled = false;
        panel.shadow = false;
        clipboard_auto_paste = "off";
        launcher = {
          categories = false;
          sort_by_usage = false;
        };
      };

      keybinds = {
        left = [
          "left"
          "ctrl+h"
        ];
        right = [
          "right"
          "ctrl+l"
        ];
        up = [
          "up"
          "ctrl+k"
        ];
        down = [
          "down"
          "ctrl+j"
        ];
      };

      # The blurred copy of the wallpaper niri shows behind its overview
      # (see the `noctalia-backdrop` layer-rule in niri/config.kdl).
      backdrop = {
        enabled = true;
        blur_intensity = 0.4;
        tint_intensity = 0.6;
      };

      wallpaper.transition_duration = 0;

      notification.layer = "overlay";

      # Volume and brightness only; the other kinds are on by default.
      osd.kinds = {
        wifi = false;
        bluetooth = false;
        power_profile = false;
        caffeine = false;
        nightlight = false;
        dnd = false;
        lock_keys = false;
        keyboard_layout = false;
        privacy = false;
      };

      nightlight.enabled = true;

      location.address = "Warsaw";

      control_center = {
        calendar.show_week_numbers = true;
        shortcuts = [
          { type = "wifi"; }
          { type = "bluetooth"; }
          { type = "notification"; }
          { type = "power_profile"; }
        ];
      };

      # A flat bar flush with the top edge, no capsules.
      bar.main = {
        position = "top";
        margin_ends = 0;
        margin_edge = 0;
        radius = 0;
        shadow = false;
        start = [ "workspaces" ];
        center = [ "clock" ];
        end = [
          "tray"
          "keyboard_layout"
          "network"
          "volume"
          "battery"
          "notifications"
          "privacy"
        ];
      };

      widget = {
        clock = {
          format = "{:%H:%M %a, %b %d}";
          tooltip_format = "{:%H:%M %a, %b %d}";
        };
        workspaces = {
          label_source = "id";
          labels_only_when_occupied = true;
          hide_when_empty = true;
          pill_scale = 0.6;
        };
        tray.hide_passive = false;
        battery = {
          display_mode = "graphic";
          show_label = false;
        };
        # Replaces the v4 privacy-indicator plugin.
        privacy = {
          hide_inactive = true;
          icon_spacing = 4;
          active_color = "error";
        };
      };
    };
  };
}
