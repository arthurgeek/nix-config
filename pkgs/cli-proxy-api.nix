# Local API bridge for Codex subscription OAuth. The source is the
# `cli-proxy-api` flake input, which Renovate bumps; the renovate-lock workflow
# then rebuilds `goModules` and rewrites `vendorHash` below on the same branch,
# so a bump never lands with a stale hash.
{
  buildGoModule,
  src,
  version,
}:
buildGoModule {
  pname = "cli-proxy-api";
  inherit version src;
  vendorHash = "sha256-r3yWkdMcM40G9jV7MxW/qNv3E9WrHavFilW24quEf+8=";
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
