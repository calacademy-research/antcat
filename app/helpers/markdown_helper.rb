# frozen_string_literal: true

module MarkdownHelper
  def markdown content
    return unless content
    Markdowns::Render[content.dup]
  end

  # For content any signed-in user can write (comments); see `Markdowns::Render::USER_CONTENT_ATTRIBUTES`.
  def user_markdown content
    return unless content
    Markdowns::Render[content.dup, user_content: true]
  end

  def markdown_without_wrapping content
    return unless content
    Markdowns::RenderWithoutWrappingP[content.dup]
  end
end
