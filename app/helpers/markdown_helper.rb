module MarkdownHelper
  def markdown content
    Markdowns::Render.new(content).call
  end

  def antcat_markdown_only content
    Markdowns::ParseAntcatHooks.new(content).call
  end
end
