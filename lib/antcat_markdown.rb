# This is more "just Markdown", but the namesapce `Markdown` is used by Red Carpet.
class AntcatMarkdown < Redcarpet::Render::HTML
  def self.render text
    options = {
      hard_wrap: true,
      space_after_headers: true,
      fenced_code_blocks: true,
      underline: false,
    }
    renderer = AntcatMarkdown.new options

    extensions = {
      autolink: true,
      superscript: true,
      disable_indented_code_blocks: true,
      tables: true,
      underline: false,
      no_intra_emphasis: true,
      strikethrough: true,
    }
    markdowner = Redcarpet::Markdown.new renderer, extensions
    markdowner.render(text).html_safe
  end

  # Without this "AntcatMarkdown" is "Markdown".
  def preprocess full_document
    AntcatMarkdownUtils.parse_antcat_hooks full_document
  end

  def table header, body
    <<-HTML
      <table class="tablesorter hover margin-top">
        <thead>#{header}</thead>
        <tbody>#{body}</tbody>
      </table>
    HTML
  end
end
