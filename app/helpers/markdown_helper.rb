# frozen_string_literal: true

module MarkdownHelper
  def markdown content, no_wrapping_p: false, sanitize_content: true
    return '' unless content
    return Markdowns::RenderWithoutWrappingP[content.dup] if no_wrapping_p
    Markdowns::Render[content.dup, sanitize_content: sanitize_content]
  end
end
