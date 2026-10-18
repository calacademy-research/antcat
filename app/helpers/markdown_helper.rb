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

  # Raw taxt as shown in "show raw" and source views: without hidden notes for visitors (see `Current`).
  def raw_taxt_for_viewer taxt
    Current.signed_in ? taxt : Taxt.remove_hidden_notes(taxt)
  end

  def markdown_without_wrapping content
    return unless content
    Markdowns::RenderWithoutWrappingP[content.dup]
  end
end
