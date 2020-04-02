# frozen_string_literal: true

module MarkdownHelper
  def markdown content, sanitize_content: true
    return unless content
    Markdowns::Render[content.dup, sanitize_content: sanitize_content]
  end

  def markdown_without_wrapping content
    return unless content
    Markdowns::RenderWithoutWrappingP[content.dup]
  end
end
