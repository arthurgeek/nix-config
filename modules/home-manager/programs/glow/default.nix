{ config, pkgs, ... }:
let
  # stylix has no glamour target, so this is glamour's built-in `dark` style
  # with its fixed colours swapped for the terminal's 16 ANSI colours, which
  # stylix sets from the system palette. Code blocks go through chroma, which
  # only takes hex, so they read the palette directly.
  c = config.lib.stylix.colors.withHashtag;
  style = (pkgs.formats.json { }).generate "glamour-stylix.json" {
    document = {
      block_prefix = "\n";
      block_suffix = "\n";
      margin = 2;
    };
    block_quote = {
      indent = 1;
      indent_token = "│ ";
      color = "8";
    };
    paragraph = { };
    list.level_indent = 2;
    heading = {
      block_suffix = "\n";
      color = "4";
      bold = true;
    };
    h1 = {
      prefix = " ";
      suffix = " ";
      color = "0";
      background_color = "4";
      bold = true;
    };
    h2.prefix = "## ";
    h3.prefix = "### ";
    h4.prefix = "#### ";
    h5.prefix = "##### ";
    h6 = {
      prefix = "###### ";
      color = "6";
      bold = false;
    };
    text = { };
    strikethrough.crossed_out = true;
    emph.italic = true;
    strong.bold = true;
    hr = {
      color = "8";
      format = "\n--------\n";
    };
    item.block_prefix = "• ";
    enumeration.block_prefix = ". ";
    task = {
      ticked = "[✓] ";
      unticked = "[ ] ";
    };
    link = {
      color = "6";
      underline = true;
    };
    link_text = {
      color = "4";
      bold = true;
    };
    image = {
      color = "5";
      underline = true;
    };
    image_text = {
      color = "8";
      format = "Image: {{.text}} →";
    };
    code = {
      prefix = " ";
      suffix = " ";
      color = "1";
      background_color = "8";
    };
    code_block = {
      margin = 2;
      chroma = {
        text.color = c.base05;
        error = {
          color = c.base00;
          background_color = c.base08;
        };
        comment.color = c.base03;
        comment_preproc.color = c.base0F;
        keyword.color = c.base0E;
        keyword_reserved.color = c.base0E;
        keyword_namespace.color = c.base0E;
        keyword_type.color = c.base0A;
        operator.color = c.base0C;
        punctuation.color = c.base05;
        name.color = c.base05;
        name_builtin.color = c.base0C;
        name_tag.color = c.base08;
        name_attribute.color = c.base0D;
        name_class.color = c.base0A;
        name_constant.color = c.base09;
        name_decorator.color = c.base0C;
        name_exception.color = c.base08;
        name_function.color = c.base0D;
        name_other.color = c.base05;
        literal.color = c.base09;
        literal_date.color = c.base0B;
        literal_number.color = c.base09;
        literal_string.color = c.base0B;
        literal_string_escape.color = c.base0C;
        generic_deleted.color = c.base08;
        generic_emph.italic = true;
        generic_inserted.color = c.base0B;
        generic_strong.bold = true;
        generic_subheading.color = c.base03;
        background.background_color = c.base01;
      };
    };
    table = { };
    definition_list = { };
    definition_term = { };
    definition_description.block_prefix = "\n🠶 ";
    html_block = { };
    html_span = { };
  };
in
{
  home.packages = [ pkgs.glow ];

  # Read by glamour itself, so glow and gh's markdown rendering both use it.
  home.sessionVariables.GLAMOUR_STYLE = "${style}";
}
