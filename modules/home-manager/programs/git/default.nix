{ pkgs, ... }:

{
  home.packages = [ pkgs.difftastic ];

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
