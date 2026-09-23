{ inputs, ... }:

{
  # nix-index-database ships a prebuilt, weekly-refreshed index, so there is no
  # hour-long `nix-index` run to do by hand. Its module turns on
  # programs.nix-index, which hooks fish's command-not-found handler to print
  # the package that provides a missing command.
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  # `, <cmd>` runs a command from nixpkgs without installing it, using the
  # same database.
  programs.nix-index-database.comma.enable = true;
}
