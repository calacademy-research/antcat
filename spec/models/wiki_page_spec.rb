# frozen_string_literal: true

require 'rails_helper'

describe WikiPage do
  it { is_expected.to be_versioned }

  # The wiki link of 13 Nov 2026 is no longer used, but its column and foreign key stay for now.
  it 'refuses to delete a page that a protonym still points to' do
    wiki_page = create :wiki_page
    create(:protonym, :species_group).update_columns(grammar_and_spelling_wiki_page_id: wiki_page.id)

    expect(wiki_page.destroy).to eq false
    expect(described_class.exists?(wiki_page.id)).to eq true
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :content }
    it { is_expected.to validate_length_of(:title).is_at_most(described_class::TITLE_MAX_LENGTH) }

    describe "uniqueness validation" do
      subject { create :wiki_page }

      it { is_expected.to validate_uniqueness_of(:title).ignoring_case_sensitivity }
      it { is_expected.to validate_uniqueness_of(:permanent_identifier).ignoring_case_sensitivity }
    end
  end

  describe ".policies" do
    it "returns the policy pages that exist, in the listed order" do
      create :wiki_page
      open_questions = create :wiki_page, permanent_identifier: described_class::OPEN_GRAMMAR_AND_SPELLING_QUESTIONS
      grammar = create :wiki_page, permanent_identifier: described_class::GRAMMAR_AND_SPELLING_POLICY

      expect(described_class.policies).to eq [grammar, open_questions]
    end
  end

  describe "permanent identifier" do
    it "stores a blank identifier as none, so that several pages can be without one" do
      create :wiki_page, permanent_identifier: ""
      wiki_page = create :wiki_page, permanent_identifier: ""

      expect(wiki_page.reload.permanent_identifier).to be_nil
    end
  end
end
