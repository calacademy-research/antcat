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
        Taxt::TAXA_FIELDS_REFERENCING_TAXA.each do |field|
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

  describe '#owner' do
    subject(:table_ref) { described_class.new(table, "_field", id) }

    let(:id) { object.id }

    context "when table is `citations`" do
      let(:table) { "citations" }
      let(:object) { create(:protonym).authorship }

      specify { expect(table_ref.owner).to eq object.protonym }
    end

    context "when table is `protonyms`" do
      let(:table) { "protonyms" }
      let!(:object) { create :protonym }

      specify { expect(table_ref.owner).to eq object }
    end

    context "when table is `reference_sections`" do
      let(:table) { "reference_sections" }
      let!(:object) { create :reference_section }

      specify { expect(table_ref.owner).to eq object.taxon }
    end

    context "when table is `references`" do
      let(:table) { "references" }
      let!(:object) { create :article_reference }

      specify { expect(table_ref.owner).to eq object }
    end

    context "when table is `taxa`" do
      let(:table) { "taxa" }
      let!(:object) { create :family }

      specify { expect(table_ref.owner).to eq object }
    end

    context "when table is `taxon_history_items`" do
      let(:table) { "taxon_history_items" }
      let!(:object) { create :taxon_history_item }

      specify { expect(table_ref.owner).to eq object.taxon }
    end
  end
end
