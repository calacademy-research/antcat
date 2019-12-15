require 'rails_helper'

describe TableRef do
  describe '#taxt?' do
    context 'when table ref is a taxt item' do
      specify do
        expect(described_class.new('citations', :notes_taxt, 999).taxt?).to eq true
        expect(described_class.new('reference_sections', :references_taxt, 999).taxt?).to eq true
        expect(described_class.new('reference_sections', :subtitle_taxt, 999).taxt?).to eq true
        expect(described_class.new('reference_sections', :title_taxt, 999).taxt?).to eq true
        expect(described_class.new('taxa', :headline_notes_taxt, 999).taxt?).to eq true
        expect(described_class.new('protonyms', :primary_type_information_taxt, 999).taxt?).to eq true
        expect(described_class.new('protonyms', :secondary_type_information_taxt, 999).taxt?).to eq true
        expect(described_class.new('protonyms', :type_notes_taxt, 999).taxt?).to eq true
        expect(described_class.new('taxa', :type_taxt, 999).taxt?).to eq true
        expect(described_class.new('taxon_history_items', :taxt, 999).taxt?).to eq true
      end
    end

    context 'when table ref is not a taxt item' do
      specify do
        Taxon::TAXA_FIELDS_REFERENCING_TAXA.each do |field|
          expect(described_class.new('taxa', field, 999).taxt?).to eq false
        end
      end
    end
  end

  describe '#detax' do
    context 'when table ref is a taxt item' do
      let!(:taxon_history_item) { create :taxon_history_item }
      let!(:table_ref) { described_class.new('taxon_history_items', :taxt, taxon_history_item.id) }

      specify { expect(table_ref.detax).to eq Detax[taxon_history_item.taxt] }
    end

    context 'when table ref is not a taxt item' do
      let!(:table_ref) { described_class.new('taxa', :species_id, 999) }

      specify { expect(table_ref.detax).to eq "&ndash;" }
    end
  end
end
