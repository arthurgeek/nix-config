# herdr from nixpkgs, patched so it refuses to overwrite the plugin registry
# when home-manager manages it as a symlink into the store. Exposed as a flake
# package so the renovate-lock workflow builds it on every Renovate branch: a
# nixpkgs bump that breaks the patch fails there, not on the next rebuild.
{ herdr }:
herdr.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./immutable-plugin-registry.patch ];
})
