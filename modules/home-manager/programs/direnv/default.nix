{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    # Silence status output (`direnv: loading`, `using flake`, `export +FOO`…).
    # The DIRENV_LOG_FORMAT env var is ignored by direnv 2.36+; silencing must
    # go through direnv.toml. `silent` makes home-manager write
    # `[global] log_format = "-"` + `log_filter = "^$"` for us.
    silent = true;
  };
}
