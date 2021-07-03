# frozen_string_literal: true

require 'rails_helper'

describe Author do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_many(:names).class_name('AuthorName').dependent(:destroy) }
    it { is_expected.to have_many(:references).dependent(:restrict_with_error) }
  end

  describe "scopes" do
    describe ".order_by_name" do
      let!(:ward) { create :author_name, name: 'Ward' }
      let!(:bolton) { create :author_name, name: 'Bolton' }
      let!(:fisher) { create :author_name, name: 'Fisher, B. L.' }

      it "sorts by first author name" do
        expect(described_class.order_by_name).to eq [bolton.author, fisher.author, ward.author]
      end
    end
  end

  describe '#described_taxa' do
    let(:author) { create :author }
    let(:author_name) { create :author_name, author: author }

    let(:reference_1) { create :any_reference, author_names: [author_name] }
    let(:reference_2) { create :any_reference, author_names: [author_name] }
    let!(:taxon_1) { create :any_taxon, protonym: create(:protonym, authorship_reference: reference_1) }
    let!(:taxon_2) { create :any_taxon, protonym: create(:protonym, authorship_reference: reference_2) }

    before { create :species } # Unrelated.

    it "returns taxa described by the author" do
      expect(author.described_taxa).to match_array [taxon_1, taxon_2]
    end
  end

  describe '#described_protonyms' do
    let(:author) { create :author }
    let(:author_name) { create :author_name, author: author }

    let(:reference_1) { create :any_reference, author_names: [author_name] }
    let(:reference_2) { create :any_reference, author_names: [create(:author_name), author_name] }
    let!(:protonym_1) { create(:protonym, authorship_reference: reference_1) }
    let!(:protonym_2) { create(:protonym, authorship_reference: reference_2) }

    before { create :protonym } # Unrelated.

    it "returns taxa described by the author" do
      expect(author.described_protonyms).to match_array [protonym_1, protonym_2]
    end
  end
end
