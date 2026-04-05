{ pkgs, lib, ... }:

let
  identityAgent =
    if pkgs.stdenv.hostPlatform.isDarwin then
      ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
    else
      "~/.1password/agent.sock";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        extraOptions = {
          UseKeychain = "yes";
          IgnoreUnknown = "UseKeychain";
          IdentityAgent = identityAgent;
        };
        identityFile = "~/.ssh/id_ed25519";
      };

      "192.168.*.*" = {
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };
    };

    extraConfig = ''
      ControlMaster auto
      ControlPath ~/.ssh/control-%C
      ControlPersist yes
    '';
  };
}
