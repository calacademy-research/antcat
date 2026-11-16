# frozen_string_literal: true

# The one page of notes on a name ("Notes on this name"): the background a protonym needs beyond its short public
# notes, in Markdown (table `notes_pages`, one row per protonym at most). Sections as needed, each a second-level
# heading: "Etymological notes" (derivation, part of speech, gender agreement and the accepted spelling), "Type
# specimen notes", "Nomenclatural notes". Shown at /protonyms/:protonym_id/notes, rendered with
# `document_markdown` (`Markdowns::RenderDocument`) so that a document written elsewhere keeps its "> quoted" lines.
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
    lines_outside_code.filter_map { |line, code| line[/\A##[ \t]+(.+?)(?:[ \t]+#+)?[ \t]*\z/, 1] unless code }
  end

  def link_label
    section_titles.presence&.join(", ") || "Notes"
  end

  private

    # Each line with whether it is inside a fenced code block (``` or ~~~), where nothing is a heading.
    # A block is closed by the kind of fence that opened it.
    def lines_outside_code
      open_fence = nil
      content.to_s.split("\n", -1).map do |line|
        fence = line[CODE_FENCE, 1]
        code = open_fence.present? || fence.present?
        if open_fence.nil?
          open_fence = fence
        elsif fence == open_fence
          open_fence = nil
        end
        [line, code]
      end
    end
end
