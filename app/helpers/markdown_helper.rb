# frozen_string_literal: true

module MarkdownHelper
  def markdown content
    return unless content
    Markdowns::Render[content.dup]
  end

  def markdown_without_wrapping content
    return unless content
    Markdowns::RenderWithoutWrappingP[content.dup]
  end
end
