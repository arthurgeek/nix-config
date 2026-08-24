{ pkgs, lib, ... }:

let
  identityAgent =
    if pkgs.stdenv.hostPlatform.isDarwin then
      ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
    else
      "~/.1password/agent.sock";
in
{
  home.sessionVariables = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
        IgnoreUnknown = "UseKeychain";
        IdentityAgent = identityAgent;
        IdentityFile = "~/.ssh/id_ed25519";
      };

      "192.168.*.*" = {
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
      };
    };

    extraConfig = ''
      ControlMaster auto
      ControlPath ~/.ssh/control-%C
      ControlPersist yes
    '';
  };
}
