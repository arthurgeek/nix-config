{ username, inputs, ... }:

{
  home-manager.users.${username} = {
    imports = [
      inputs.noctalia.homeModules.default
      ../wayland-common
    ];

    programs.noctalia-shell = {
      enable = true;
      settings = {
        idle = {
          enabled = true;
          lockTimeout = 300;
          screenOffTimeout = 360;
          screenOffCommand = "niri msg action power-off-monitors";
          resumeScreenOffCommand = "niri msg action power-on-monitors";
          lockCommand = "noctalia-shell ipc call lockScreen lock";
        };
        wallpaper = {
          enabled = true;
          fillMode = "crop";
        };
        general = {
          lockOnSuspend = true;
        };
      };
      plugins = {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {
          privacy-indicator = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          screen-recorder = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          clipper = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          polkit-agent = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          neovim-session-provider = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          file-search = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          weather-indicator = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          screenshot = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
        version = 1;
      };
      pluginSettings = {
        privacy-indicator = {
          hideInactive = true;
          enableToast = false;
          iconSpacing = 4;
          removeMargins = true;
          activeColor = "error";
          inactiveColor = "none";
        };
        screen-recorder = {
          audioCodec = "opus";
          audioSource = "none";
          copyToClipboard = false;
          filenamePattern = "recording_yyyyMMdd_HHmmss";
          frameRate = "60";
          hideInactive = true;
          quality = "very_high";
          showCursor = true;
          videoCodec = "h264";
          videoSource = "portal";
        };
      };
    };

    xdg.configFile."niri/config.kdl".source = ./config.kdl;
  };
}
