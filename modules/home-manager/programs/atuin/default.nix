{
  lib,
  pkgs,
  ...
}:
let
  tomlFormat = pkgs.formats.toml { };
  atuinBaseConfig = tomlFormat.generate "atuin-base-config" {
    search_mode = "fuzzy";
    style = "compact";
    inline_height = 25;
    inline_height_shell_up_key_binding = 25;
    filter_mode_shell_up_key_binding = "directory";
    show_preview = true;
    update_check = false;
    enter_accept = true;
  };

  atuinTemplate = pkgs.runCommand "atuin-config.toml.tpl" { } ''
    cat ${atuinBaseConfig} > $out
    printf '\nsync_address = "{{ op://Secrets/atuin/sync_address }}"\n' >> $out
  '';

  atuinSyncSetup = pkgs.writeShellScriptBin "atuin-sync-setup" ''
    set -euo pipefail
    op_bin="/usr/local/bin/op"
    config="$HOME/.config/atuin/config.toml"

    if [ ! -x "$op_bin" ]; then
      echo "Error: 1Password CLI not found at $op_bin" >&2
      exit 1
    fi

    echo "Injecting Atuin sync address from 1Password..."
    "$op_bin" inject -i "${atuinTemplate}" -o "$config" -f
    chmod 600 "$config"
    echo "Successfully updated $config with 1Password sync address."
  '';
in
{
  home.packages = [ atuinSyncSetup ];

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  # Materialize ~/.config/atuin/config.toml.
  # If sync_address is already configured, preserve it without querying 1Password.
  # Only query 1Password if sync_address is missing (e.g. first run on a fresh machine).
  home.activation.atuinConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    configDir="$HOME/.config/atuin"
    configFile="$configDir/config.toml"
    workdir="$(${pkgs.coreutils}/bin/mktemp -d)"
    trap '${pkgs.coreutils}/bin/rm -rf "$workdir"' EXIT

    prev_sync=""
    if [ -f "$configFile" ]; then
      prev_sync="$(${pkgs.gnused}/bin/sed -n 's/^sync_address = "\(.*\)"/\1/p' "$configFile" 2>/dev/null || true)"
    fi

    if [ -n "$prev_sync" ]; then
      # Already configured: apply declarative base settings and keep existing sync_address (0s overhead, no 1P prompt)
      ${pkgs.coreutils}/bin/cp "${atuinBaseConfig}" "$workdir/config.toml"
      ${pkgs.coreutils}/bin/chmod u+w "$workdir/config.toml"
      printf '\nsync_address = "%s"\n' "$prev_sync" >> "$workdir/config.toml"
    else
      # Not configured: query 1Password on first run
      op_bin="/usr/local/bin/op"
      injected=0

      if [ -x "$op_bin" ]; then
        if "$op_bin" inject -i "${atuinTemplate}" -o "$workdir/config.toml" -f 2>/dev/null; then
          injected=1
        fi
      fi

      if [ "$injected" -eq 0 ]; then
        ${pkgs.coreutils}/bin/cp "${atuinBaseConfig}" "$workdir/config.toml"
        echo >&2 "Note: 1Password CLI could not resolve 'op://Secrets/atuin/sync_address'."
        echo >&2 "      Atuin is running with local history. Once 1Password is set up and CLI integration"
        echo >&2 "      is enabled, Atuin will automatically configure sync when you launch Fish."
      fi
    fi

    run ${pkgs.coreutils}/bin/mkdir -p "$configDir"
    run ${pkgs.coreutils}/bin/rm -f "$configFile"
    run ${pkgs.coreutils}/bin/install -m600 "$workdir/config.toml" "$configFile"
  '';

  # Self-healing hook: When Fish starts interactively, only runs if sync_address is still missing
  # (e.g. initial bootstrap before 1Password login). Once populated, this check is a no-op (<1ms).
  programs.fish.interactiveShellInit = lib.mkAfter ''
    if test -f ~/.config/atuin/config.toml; and not ${pkgs.gnugrep}/bin/grep -q '^sync_address' ~/.config/atuin/config.toml 2>/dev/null
        if test -x /usr/local/bin/op
            fish -c '
                if /usr/local/bin/op inject -i "${atuinTemplate}" -o "$HOME/.config/atuin/config.toml" -f >/dev/null 2>&1
                    echo "✨ Atuin: sync address successfully configured from 1Password!"
                end
            ' &
            disown
        end
    end
  '';
}
