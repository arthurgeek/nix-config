{ config, ... }:
{
  programs.spotify-player = {
    enable = true;
    settings = {
      # Our own Spotify app instead of the shared default client, which is
      # rate-limited across every spotify-player user. Registered at
      # https://developer.spotify.com/dashboard with redirect URI
      # http://127.0.0.1:8989/login (spotify-player's login_redirect_uri).
      # The ID lives outside the repo; spotify-player runs this command to
      # read it.
      client_id_command = {
        command = "cat";
        args = [ "${config.xdg.configHome}/spotify-player/client_id" ];
      };

      # Album art is drawn through the terminal's image protocol (Ghostty's
      # kitty graphics). nixpkgs builds spotify-player without the `pixelate`
      # feature, so there is no block-pixel fallback to turn off.
      enable_cover_image_cache = true;
    };
  };
}
