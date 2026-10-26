# Local API bridge for Codex subscription OAuth. The source is the
# `cli-proxy-api` flake input, which Renovate bumps; the renovate-lock workflow
# then rebuilds `goModules` and rewrites `vendorHash` below on the same branch,
# so a bump never lands with a stale hash.
#
# Upstream's go.mod tracks the newest Go patch release, which nixpkgs's default
# `buildGoModule` (one minor behind) does not always satisfy. Build with the
# latest Go nixpkgs ships instead; the toolchain cannot be downloaded at build
# time because nixpkgs sets GOTOOLCHAIN=local.
{
  buildGoLatestModule,
  src,
  version,
}:
buildGoLatestModule {
  pname = "cli-proxy-api";
  inherit version src;
  vendorHash = "sha256-yMO0DdE0pjtFxWaQXV17enV8u0KA5fIUbE8Gui/RvWU=";
  subPackages = [ "cmd/server" ];
  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=v${version}"
    "-X=main.Commit=${src.rev}"
  ];
  postInstall = ''
    mv "$out/bin/server" "$out/bin/cli-proxy-api"
  '';
  meta.mainProgram = "cli-proxy-api";
}
