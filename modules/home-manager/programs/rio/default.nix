{ ... }:
{
  programs.rio = {
    enable = true;
    settings = {
      fonts = {
        family = "FiraCode Nerd Font Mono";
        size = 18;
        # Rio doesn't use CoreText's automatic font fallback; map the
        # Misc Technical tail (⏰..⏿, includes ⏵⏸ used by Claude Code's
        # status indicator) to a font that actually has those glyphs.
        symbol-map = [
          {
            start = "23F0";
            end = "23FF";
            font-family = "STIX Two Math";
          }
        ];
      };
      option-as-alt = "both";
    };
  };
}
