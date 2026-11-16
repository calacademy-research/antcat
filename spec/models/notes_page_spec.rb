# frozen_string_literal: true

require 'rails_helper'

describe NotesPage do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:protonym).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :content }

    it 'allows one page of notes per protonym' do
      notes_page = create :notes_page
      second = build :notes_page, protonym: notes_page.protonym

      expect(second.valid?).to eq false
      expect(second.errors.where(:protonym_id).map(&:message)).to include("has already been taken")
    end
  end

  describe '#section_titles and #link_label' do
    it 'reads the second-level headings of the page' do
      notes_page = described_class.new(content: "## Etymological notes\n\nText.\n\n### Test A\n\n## Type specimen notes ##\n\nText.")

      expect(notes_page.section_titles).to eq ["Etymological notes", "Type specimen notes"]
      expect(notes_page.link_label).to eq "Etymological notes, Type specimen notes"
    end

    it 'falls back to "Notes" for a page without headings' do
      expect(described_class.new(content: "Just text.").link_label).to eq "Notes"
    end

    it 'does not read a heading inside a code block' do
      notes_page = described_class.new(content: "## Type specimen notes\n\n```\n## not a heading\n```")

      expect(notes_page.section_titles).to eq ["Type specimen notes"]
    end
  end

  describe 'line endings' do
    it "stores a form's CR LF line endings as LF" do
      notes_page = create :notes_page, content: "## Etymological notes\r\n\r\nText."

      expect(notes_page.content).to eq "## Etymological notes\n\nText."
      expect(notes_page.section_titles).to eq ["Etymological notes"]
    end
  end

  describe '#content_for_rendering' do
    it 'turns Markdown quotations into blockquotes, which survive the sanitizer' do
      notes_page = described_class.new(content: "Text.\n\n> **Spelling.** Originally described as *crassispina*.\n\nMore.")

      expect(notes_page.content_for_rendering).
        to eq "Text.\n\n<blockquote><b>Spelling.</b> Originally described as <i>crassispina</i>.</blockquote>\n\nMore."
    end

    it 'leaves a ">" inside a line alone' do
      expect(described_class.new(content: "a > b").content_for_rendering).to eq "a > b"
    end

    it 'leaves a quoted line inside a code block alone' do
      content = "```\n> not a quote\n```"

      expect(described_class.new(content: content).content_for_rendering).to eq content
    end

    it 'is still sanitized when rendered: markup in a quoted line cannot run a script' do
      notes_page = described_class.new(content: "> <script>alert(1)</script>quoted <a href=\"javascript:alert(1)\" onclick=\"alert(1)\">link</a>")
      html = Markdowns::Render[notes_page.content_for_rendering]

      expect(html).to include "<blockquote>"
      expect(html).to include "quoted"
      expect(html).not_to include "<script"
      expect(html).not_to include "onclick"
      expect(html).not_to include "javascript:"
    end
  end
end
