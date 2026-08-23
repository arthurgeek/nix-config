{ ... }:
{
  # The daemon only; `tailscale up` still has to be run once by hand to
  # authenticate this machine against the tailnet.
  services.tailscale.enable = true;
}
