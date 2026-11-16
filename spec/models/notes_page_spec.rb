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

    it 'keeps a "#" that belongs to the title' do
      expect(described_class.new(content: "## Specimen CASENT0100001 #").section_titles).to eq ["Specimen CASENT0100001"]
      expect(described_class.new(content: "## Type #2").section_titles).to eq ["Type #2"]
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
end
