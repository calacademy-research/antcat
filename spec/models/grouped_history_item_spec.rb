# frozen_string_literal: true

require 'rails_helper'

describe GroupedHistoryItem, :relational_hi do
  subject(:grouped_history_item) { described_class.new([item, item]) }

  describe '#taxt' do
    context 'with `TAXT` items' do
      let(:item) { create :history_item, :taxt }

      specify { expect(grouped_history_item.taxt).to eq item.to_taxt }
    end

    context 'with `TYPE_SPECIMEN_DESIGNATION` items' do
      context 'with subtype `LECTOTYPE_DESIGNATION`' do
        let(:item) { create :history_item, :lectotype_designation }

        specify { expect(grouped_history_item.taxt).to eq item.to_taxt }
      end

      context 'with subtype `NEOTYPE_DESIGNATION`' do
        let(:item) { create :history_item, :neotype_designation }

        specify { expect(grouped_history_item.taxt).to eq item.to_taxt }
      end
    end

    context 'with `FORM_DESCRIPTIONS` items' do
      let(:item) { create :history_item, :form_descriptions }

      specify do
        expect(grouped_history_item.taxt).
          to eq "#{item.citation_taxt} (#{item.text_value}); #{item.citation_taxt} (#{item.text_value})."
      end
    end

    context 'with `COMBINATION_IN` items' do
      let(:item) { create :history_item, :combination_in }

      specify do
        expect(grouped_history_item.taxt).
          to eq "Combination in {#{Taxt::TAX_TAG} #{item.object_taxon.id}}: #{item.citation_taxt}; #{item.citation_taxt}."
      end
    end

    context 'with `JUNIOR_SYNONYM_OF` items' do
      let(:item) { create :history_item, :junior_synonym_of }

      specify do
        expect(grouped_history_item.taxt).
          to eq "Junior synonym of {#{Taxt::PROTT_TAG} #{item.object_protonym.id}}: #{item.citation_taxt}; #{item.citation_taxt}."
      end
    end

    context 'with `SENIOR_SYNONYM` items' do
      let(:item) { create :history_item, :senior_synonym_of }

      specify do
        expect(grouped_history_item.taxt).
          to eq "Senior synonym of {#{Taxt::PROTT_TAG} #{item.object_protonym.id}}: #{item.citation_taxt}; #{item.citation_taxt}."
      end
    end

    context 'with `STATUS_AS_SPECIES` items' do
      let(:item) { create :history_item, :status_as_species }

      specify do
        expect(grouped_history_item.taxt).
          to eq "Status as species: #{item.citation_taxt}; #{item.citation_taxt}."
      end
    end

    context 'with `SUBSPECIES_OF` items' do
      let(:item) { create :history_item, :subspecies_of }

      specify do
        expect(grouped_history_item.taxt).
          to eq "Subspecies of {#{Taxt::PROTT_TAG} #{item.object_protonym.id}}: #{item.citation_taxt}; #{item.citation_taxt}."
      end
    end
  end
end
