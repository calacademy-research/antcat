# frozen_string_literal: true

# Renders Markdown: editors' content and user content (comments, with fewer allowed attributes), and raw taxt
# without hidden notes for visitors.
module MarkdownHelper
  # `blockquotes: true` for content written as a document (a name's page of notes): "> quoted" lines are quotes.
  def markdown content, blockquotes: false
    return unless content
    Markdowns::Render[content.dup, blockquotes: blockquotes]
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
