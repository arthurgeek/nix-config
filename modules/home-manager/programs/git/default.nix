{ pkgs, lib, ... }:

let
  # core.hooksPath makes git ignore per-repo .git/hooks entirely, so every
  # global hook must fall through to the repo's own hook of the same name.
  passthroughHooks = [
    "applypatch-msg"
    "pre-applypatch"
    "post-applypatch"
    "pre-commit"
    "pre-merge-commit"
    "commit-msg"
    "post-commit"
    "pre-rebase"
    "post-checkout"
    "post-merge"
    "pre-push"
    "post-rewrite"
  ];

  passthroughHook = name: {
    name = ".config/git/hooks/${name}";
    value = {
      executable = true;
      text = ''
        #!/bin/sh
        repo_hook="$(git rev-parse --git-dir)/hooks/${name}"
        [ -x "$repo_hook" ] && exec "$repo_hook" "$@"
        exit 0
      '';
    };
  };
in
{
  home.packages = [ pkgs.difftastic ];

  home.file = lib.listToAttrs (map passthroughHook passthroughHooks) // {
    ".ssh/allowed_signers".text =
      "arthurgeek@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCNZvPuY0ibJEJdP/dt2IfL0gkJBnd4I9anjmLNtgap\n";

    ".config/git/hooks/prepare-commit-msg" = {
      executable = true;
      text = ''
        #!/bin/sh
        git interpret-trailers --if-exists doNothing \
          --trailer "Signed-off-by: $(git config user.name) <$(git config user.email)>" \
          --in-place "$1"

        repo_hook="$(git rev-parse --git-dir)/hooks/prepare-commit-msg"
        [ -x "$repo_hook" ] && exec "$repo_hook" "$@"
        exit 0
      '';
    };
  };

  programs.git = {
    enable = true;

    ignores = [
      ".DS_Store"
      ".vscode"
      ".worktrees"
    ];

    attributes = [
      "*.gif diff=exif"
      "*.jpg diff=exif"
      "*.png diff=exif"
    ];

    settings = {
      user = {
        name = "Arthur Zapparoli";
        email = "arthurgeek@users.noreply.github.com";
        signingkey = "key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCNZvPuY0ibJEJdP/dt2IfL0gkJBnd4I9anjmLNtgap";
      };

      commit.gpgsign = true;

      gpg = {
        format = "ssh";
        ssh = {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          allowedSignersFile = "~/.ssh/allowed_signers";
        };
      };

      alias = {
        co = "checkout";
        st = "status -s -b";
        wdiff = "diff --word-diff";
        slog = "log";
        oops = "!git add . && git commit --amend --no-edit && git push --force-with-lease";
        difi = "!difi";
      };

      apply.whitespace = "fix";

      core = {
        hooksPath = "~/.config/git/hooks";
        whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
        trustctime = false;
        precomposeunicode = false;
        untrackedCache = true;
        editor = "hx";
      };

      format.pretty = "%C(yellow)%h%Creset%Cred%d%Creset %s %Cblue[%an] %Cgreen%ar";

      diff = {
        renames = "copies";
        tool = "difftastic";
        colorMoved = "default";
        bin.textconv = "hexdump -v -C";
        exif.textconv = "exiftool";
      };

      difftool = {
        prompt = false;
        difftastic.cmd = ''difft "$LOCAL" "$REMOTE"'';
      };

      help.autocorrect = 1;

      merge = {
        log = true;
        tool = "vimdiff";
        conflictstyle = "diff3";
      };

      push = {
        default = "simple";
        followTags = true;
      };

      rerere.enabled = true;

      github.user = "arthurgeek";

      init.defaultBranch = "main";
    };
  };
}
