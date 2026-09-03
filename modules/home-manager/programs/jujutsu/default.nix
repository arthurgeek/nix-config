{
  config,
  inputs,
  userConfig,
  pkgs,
  lib,
  ...
}:

let
  lazyjjConfigFiles = [
    "aliases"
    "claude"
    "github"
    "revsets"
    "self"
    "shortcuts"
    "stack"
  ];

  lazyjjConfigFile = name: {
    name = "jj/conf.d/lazyjj-${name}.toml";
    value.source = "${inputs.lazyjj-config}/config/lazyjj-${name}.toml";
  };

  deltaConfig = [
    "--config"
    "ui.diff-formatter=:git"
    "--config"
    "ui.pager=${lib.getExe config.programs.delta.finalPackage}"
  ];

  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCNZvPuY0ibJEJdP/dt2IfL0gkJBnd4I9anjmLNtgap";
  onePasswordSigner =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      lib.getExe' pkgs._1password-gui "op-ssh-sign";
in
{
  home.packages = with pkgs; [
    coreutils
    jj-fzf
    lazyjj
  ];

  xdg.configFile = lib.listToAttrs (map lazyjjConfigFile lazyjjConfigFiles) // {
    "jj/conf.d/zzz-lazyjj-herdr.toml".source = ./lazyjj-herdr.toml;
    "jj/conf.d/zzz-lazyjj-nix.toml".text = ''
      [aliases]
      lazyjj-update = ["util", "exec", "--", "sh", "-c", "echo 'LazyJJ is managed by Nix; update the lazyjj-config flake input instead.'"]
    '';
  };

  programs.jujutsu = {
    enable = true;

    settings = {
      aliases = {
        ddiff = [ "diff" ] ++ deltaConfig;
        dlog = [
          "log"
          "-p"
        ]
        ++ deltaConfig;
        dshow = [ "show" ] ++ deltaConfig;
      };

      user = {
        name = userConfig.fullName;
        email = userConfig.email;
      };

      ui = {
        editor = "hx";
        diff-formatter = [
          (lib.getExe pkgs.difftastic)
          "--color=always"
          "$left"
          "$right"
        ];
      };

      signing = {
        behavior = "drop";
        backend = "ssh";
        key = signingKey;
        backends.ssh = {
          program = onePasswordSigner;
          allowed-signers = "~/.ssh/allowed_signers";
        };
      };

      git.sign-on-push = true;
      templates.commit_trailers = "format_signed_off_by_trailer(self)";
    };
  };
}
