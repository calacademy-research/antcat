module MarkdownHelper
  def markdown content, no_wrappring_p: false
    return '' unless content
    return Markdowns::RenderWithoutWrappingP[content.dup] if no_wrappring_p
    Markdowns::Render[content.dup]
  end

  def antcat_markdown_only content
    Markdowns::ParseAntcatHooks[content]
  end
end
