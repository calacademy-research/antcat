# frozen_string_literal: true

require 'rails_helper'

describe TaxonHistoryItem do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:protonym).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :taxt }
    it { is_expected.to validate_inclusion_of(:rank).in_array(Rank::AntCatSpecific::TYPE_SPECIFIC_TAXON_HISTORY_ITEM_TYPES) }
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:taxt, :rank) }

    it_behaves_like "a taxt column with cleanup", :taxt do
      subject { build :taxon_history_item }
    end
  end

  describe '.search' do
    let!(:lasius_item) { create :taxon_history_item, taxt: "Lasius content" }
    let!(:formica_123_item) { create :taxon_history_item, taxt: "Formica content 123" }

    context "with search type 'LIKE'" do
      specify do
        expect(described_class.search('cont', 'LIKE')).to match_array [lasius_item, formica_123_item]
        expect(described_class.search('lasius', 'LIKE')).to match_array [lasius_item]
        expect(described_class.search('content \d\d\d', 'LIKE')).to match_array []
      end
    end

    context "with search type 'REGEXP'" do
      specify do
        expect(described_class.search('cont', 'REGEXP')).to match_array [lasius_item, formica_123_item]
        expect(described_class.search('lasius', 'REGEXP')).to match_array [lasius_item]
        expect(described_class.search('content [0-9]', 'REGEXP')).to match_array [formica_123_item]
      end
    end

    context "with unknown search type" do
      specify do
        expect { described_class.search('cont', 'PIZZA') }.to raise_error("unknown search_type PIZZA")
      end
    end
  end

  describe '.exclude_search' do
    let!(:lasius_item) { create :taxon_history_item, taxt: "Lasius content" }
    let!(:formica_123_item) { create :taxon_history_item, taxt: "Formica content 123" }

    context "with search type 'LIKE'" do
      specify do
        expect(described_class.exclude_search('cont', 'LIKE')).to match_array []
        expect(described_class.exclude_search('lasius', 'LIKE')).to match_array [formica_123_item]
        expect(described_class.exclude_search('content [0-9]', 'LIKE')).to match_array [lasius_item, formica_123_item]
      end
    end

    context "with search type 'REGEXP'" do
      specify do
        expect(described_class.exclude_search('cont', 'REGEXP')).to match_array []
        expect(described_class.exclude_search('lasius', 'REGEXP')).to match_array [formica_123_item]
        expect(described_class.exclude_search('content [0-9]', 'REGEXP')).to match_array [lasius_item]
      end
    end

    context "with unknown search type" do
      specify do
        expect { described_class.exclude_search('cont', 'PIZZA') }.to raise_error("unknown search_type PIZZA")
      end
    end
  end

  describe '#ids_from_tax_or_taxac_tags' do
    context 'when taxt contains no tax or taxac tags' do
      let!(:history_item) { create :taxon_history_item, taxt: 'pizza festival' }

      specify { expect(history_item.ids_from_tax_or_taxac_tags).to eq [] }
    end

    context 'when taxt contains tax or taxac tags' do
      let(:taxon_1) { create :any_taxon }
      let(:taxon_2) { create :any_taxon }
      let!(:history_item) { create :taxon_history_item, taxt: "{tax #{taxon_1.id}}, {taxac #{taxon_2.id}}" }

      it 'returns IDs of taxa referenced in tax and taxac tags' do
        expect(history_item.ids_from_tax_or_taxac_tags).to match_array [taxon_1.id, taxon_2.id]
      end
    end
  end
end
