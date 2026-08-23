{ userConfig, ... }:
{
  # nordvpnd plus the CLI. Log in once with `nordvpn login`; the daemon keeps
  # the session afterwards.
  services.nordvpn.enable = true;

  # The CLI talks to nordvpnd over a socket owned by this group, so membership
  # is what makes `nordvpn` usable without sudo. The module creates the group.
  users.users.${userConfig.name}.extraGroups = [ "nordvpn" ];
}
