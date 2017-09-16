module MarkdownHelper
  def markdown content
    Markdowns::Render[content]
  end

  def antcat_markdown_only content
    Markdowns::ParseAntcatHooks[content]
  end
end
