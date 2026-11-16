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
  end
end
