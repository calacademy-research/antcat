# frozen_string_literal: true

# The one page of notes on a name ("Notes on this name"): the background a protonym needs beyond its short public
# notes, in Markdown (table `notes_pages`, one row per protonym at most). Sections as needed, each a second-level
# heading: "Etymological notes" (derivation, part of speech, gender agreement and the accepted spelling), "Type
# specimen notes", "Nomenclatural notes". Shown at /protonyms/:protonym_id/notes.
class NotesPage < ApplicationRecord
  include Trackable

  SECTIONS = ["Etymological notes", "Type specimen notes", "Nomenclatural notes"]
  CODE_FENCE = /\A\s*(```|~~~)/

  belongs_to :protonym

  # A browser sends a textarea's lines with CR LF; stored with LF, as an .md file has them.
  before_validation { self.content = content.gsub(/\r\n?/, "\n") if content }

  validates :content, presence: true
  validates :protonym_id, uniqueness: true

  has_paper_trail
  trackable parameters: proc { { protonym_id: protonym_id, protonym_name: protonym.name.name } }

  # The headings of the page ("## Etymological notes"), for the link text on the name's pages.
  def section_titles
    lines_outside_code.filter_map { |line, code| line[/\A##[ \t]+(.+?)[ \t#]*\z/, 1] unless code }
  end

  def link_label
    section_titles.presence&.join(", ") || "Notes"
  end

  # Markdown's "> quoted" lines as `<blockquote>`: the renderer sanitizes its input first, which turns the ">" of
  # a quote into "&gt;", so a document written elsewhere (an .md file) would lose its quotes. Markdown is not read
  # inside an HTML block, so the emphasis of a quoted line (`*italic*`, `**bold**`) is written as tags here. The
  # result still goes through the renderer's sanitizer (`markdown` in the views), like any other content.
  def content_for_rendering
    lines_outside_code.map do |line, code|
      next line if code || !(quoted = line[/\A>[ \t]?(.*)\z/, 1])

      "<blockquote>#{quoted.gsub(/\*\*(.+?)\*\*/, '<b>\1</b>').gsub(/\*(.+?)\*/, '<i>\1</i>')}</blockquote>"
    end.join("\n")
  end

  private

    # Each line with whether it is inside a fenced code block (``` or ~~~), where nothing is a heading or a quote.
    def lines_outside_code
      in_code = false
      content.to_s.split("\n", -1).map do |line|
        fence = line.match?(CODE_FENCE)
        code = in_code || fence
        in_code = !in_code if fence
        [line, code]
      end
    end
end
