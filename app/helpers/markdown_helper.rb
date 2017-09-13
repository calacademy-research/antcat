module MarkdownHelper
  def markdown text
    AntcatMarkdown.render text
  end

  def antcat_markdown_only text
    AntcatMarkdownUtils.parse_antcat_hooks text
  end
end
