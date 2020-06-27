# frozen_string_literal: true

require 'rails_helper'

describe TaxonHistoryItem do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:taxon).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :taxt }
    it { is_expected.to validate_inclusion_of(:rank).in_array(Rank::TYPE_SPECIFIC_TAXON_HISTORY_ITEM_TYPES) }
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:taxt, :rank) }

    it_behaves_like "a taxt column with cleanup", :taxt do
      subject { build :taxon_history_item }
    end
  end

  describe '#ids_from_tax_tags' do
    context 'when taxt contains no tax or taxac tags' do
      let!(:history_item) { create :taxon_history_item, taxt: 'pizza festival' }

      specify { expect(history_item.ids_from_tax_tags).to eq [] }
    end

    context 'when taxt contains tax or taxac tags' do
      let(:taxon_1) { create :any_taxon }
      let(:taxon_2) { create :any_taxon }
      let!(:history_item) { create :taxon_history_item, taxt: "{tax #{taxon_1.id}}, {taxac #{taxon_2.id}}" }

      it 'returns IDs of taxa referenced in tax and taxac tags' do
        expect(history_item.ids_from_tax_tags).to match_array [taxon_1.id, taxon_2.id]
      end
    end
  end
end
