module MarkdownHelper
  def markdown text
    AntcatMarkdown.render text
  end

  def antcat_markdown_only content
    Markdowns::ParseAntcatHooks.new(content).call
  end
end
