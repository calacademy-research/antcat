# frozen_string_literal: true

# The one page of notes on a name ("Notes on this name"): the background a protonym needs beyond its short public
# notes, in Markdown (table `notes_pages`, one row per protonym at most). Sections as needed, each a second-level
# heading: "Etymological notes" (derivation, part of speech, gender agreement and the accepted spelling), "Type
# specimen notes", "Nomenclatural notes". Shown at /protonyms/:protonym_id/notes.
class NotesPage < ApplicationRecord
  include Trackable

  SECTIONS = ["Etymological notes", "Type specimen notes", "Nomenclatural notes"]

  belongs_to :protonym

  validates :content, presence: true
  validates :protonym_id, uniqueness: true

  has_paper_trail
  trackable parameters: proc { { protonym_id: protonym_id, protonym_name: protonym.name.name } }

  # The headings of the page ("## Etymological notes"), for the link text on the name's pages.
  def section_titles
    content.to_s.scan(/^##[ \t]+(.+?)[ \t#]*$/).flatten
  end

  def link_label
    section_titles.presence&.join(", ") || "Notes"
  end

  # Markdown's "> quoted" lines as `<blockquote>`: the renderer sanitizes its input first, which turns the ">" of
  # a quote into "&gt;", so a document written elsewhere (an .md file) would lose its quotes. Markdown is not read
  # inside an HTML block, so the emphasis of a quoted line (`*italic*`, `**bold**`) is written as tags here.
  def content_for_rendering
    content.to_s.gsub(/^>[ \t]?(.*)$/) do
      quoted = Regexp.last_match(1).gsub(/\*\*(.+?)\*\*/, '<b>\1</b>').gsub(/\*(.+?)\*/, '<i>\1</i>')
      "<blockquote>#{quoted}</blockquote>"
    end
  end
end
