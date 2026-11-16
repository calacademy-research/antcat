# frozen_string_literal: true

# Renders Markdown: editors' content, user content (comments, with fewer allowed attributes) and whole documents
# (notes pages), and raw taxt without hidden notes for visitors.
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

  # For a whole document (a notes page): Markdown read as written, quotations included; the HTML it produces is
  # sanitized. See `Markdowns::RenderDocument`.
  def document_markdown content
    return unless content
    Markdowns::RenderDocument[content.dup]
  end

  def markdown_without_wrapping content
    return unless content
    Markdowns::RenderWithoutWrappingP[content.dup]
  end
end
