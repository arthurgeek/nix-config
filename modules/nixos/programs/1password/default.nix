{ userConfig, ... }:
{
  # Installed through the NixOS modules rather than home.packages: only these
  # set up the polkit policy and the setgid browser-support helper that system
  # authentication and browser integration depend on.
  programs._1password.enable = true;

  programs._1password-gui = {
    enable = true;
    # Grants this user CLI integration and system authentication.
    polkitPolicyOwners = [ userConfig.name ];
  };
}
