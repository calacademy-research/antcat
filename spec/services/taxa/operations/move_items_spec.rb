# frozen_string_literal: true

require 'rails_helper'

describe Taxa::Operations::MoveItems do
  describe "#call" do
    describe 'moving history items' do
      let!(:from_taxon) { create :any_taxon }
      let!(:to_taxon) { create :any_taxon }
      let!(:history_item_1) { create :taxon_history_item, taxon: from_taxon }
      let!(:history_item_2) { create :taxon_history_item, taxon: from_taxon }
      let!(:history_item_3) { create :taxon_history_item, taxon: from_taxon }

      context 'when moving all history items belonging to a taxon' do
        let(:history_items) { [history_item_1, history_item_2, history_item_3] }

        it 'moves history items from a taxon to another with correct positions' do
          expect(history_items.map(&:taxon).uniq).to eq [from_taxon]
          expect(history_items.map(&:position)).to eq [1, 2, 3]

          described_class[to_taxon, history_items: history_items]

          history_items.map(&:reload)
          expect(history_items.map(&:taxon).uniq).to eq [to_taxon]
          expect(history_items.map(&:position)).to eq [1, 2, 3]
        end
      end

      context 'when moving some but not all items belonging to a taxon' do
        let!(:history_item_4) { create :taxon_history_item, taxon: from_taxon }

        let(:history_items) { [history_item_1, history_item_2, history_item_3] }

        it 'updates positions of history items that were not moved' do
          expect(history_items.map(&:taxon).uniq).to eq [from_taxon]
          expect(history_items.map(&:position)).to eq [1, 2, 3]
          expect(history_item_4.taxon).to eq from_taxon
          expect(history_item_4.position).to eq 4

          described_class[to_taxon, history_items: history_items]

          history_items.map(&:reload)
          expect(history_items.map(&:taxon).uniq).to eq [to_taxon]
          expect(history_items.map(&:position)).to eq [1, 2, 3]

          history_item_4.reload
          expect(history_item_4.taxon).to eq from_taxon
          expect(history_item_4.position).to eq 1
        end
      end

      context 'when `to_taxon` has history items of its own' do
        let(:history_items) { [history_item_1, history_item_2, history_item_3] }

        before do
          create :taxon_history_item, taxon: to_taxon
        end

        it 'places moved history items last in correct order' do
          expect(history_items.map(&:taxon).uniq).to eq [from_taxon]
          expect(history_items.map(&:position)).to eq [1, 2, 3]

          described_class[to_taxon, history_items: history_items]

          history_items.map(&:reload)
          expect(history_items.map(&:taxon).uniq).to eq [to_taxon]
          expect(history_items.map(&:position)).to eq [2, 3, 4]
        end
      end
    end

    describe 'moving reference sections' do
      let!(:from_taxon) { create :family }
      let!(:to_taxon) { create :family }
      let!(:reference_section_1) { create :reference_section, taxon: from_taxon }
      let!(:reference_section_2) { create :reference_section, taxon: from_taxon }
      let!(:reference_section_3) { create :reference_section, taxon: from_taxon }

      context 'when moving all reference sections belonging to a taxon' do
        let(:reference_sections) { [reference_section_1, reference_section_2, reference_section_3] }

        it 'moves reference sections from a taxon to another with correct positions' do
          expect(reference_sections.map(&:taxon).uniq).to eq [from_taxon]
          expect(reference_sections.map(&:position)).to eq [1, 2, 3]

          described_class[to_taxon, reference_sections: reference_sections]

          reference_sections.map(&:reload)
          expect(reference_sections.map(&:taxon).uniq).to eq [to_taxon]
          expect(reference_sections.map(&:position)).to eq [1, 2, 3]
        end
      end

      context 'when moving some but not all items belonging to a taxon' do
        let!(:reference_section_4) { create :reference_section, taxon: from_taxon }

        let(:reference_sections) { [reference_section_1, reference_section_2, reference_section_3] }

        it 'updates positions of reference sections that were not moved' do
          expect(reference_sections.map(&:taxon).uniq).to eq [from_taxon]
          expect(reference_sections.map(&:position)).to eq [1, 2, 3]
          expect(reference_section_4.taxon).to eq from_taxon
          expect(reference_section_4.position).to eq 4

          described_class[to_taxon, reference_sections: reference_sections]

          reference_sections.map(&:reload)
          expect(reference_sections.map(&:taxon).uniq).to eq [to_taxon]
          expect(reference_sections.map(&:position)).to eq [1, 2, 3]

          reference_section_4.reload
          expect(reference_section_4.taxon).to eq from_taxon
          expect(reference_section_4.position).to eq 1
        end
      end

      context 'when `to_taxon` has reference sections of its own' do
        let(:reference_sections) { [reference_section_1, reference_section_2, reference_section_3] }

        before do
          create :reference_section, taxon: to_taxon
        end

        it 'places moved reference sections last in correct order' do
          expect(reference_sections.map(&:taxon).uniq).to eq [from_taxon]
          expect(reference_sections.map(&:position)).to eq [1, 2, 3]

          described_class[to_taxon, reference_sections: reference_sections]

          reference_sections.map(&:reload)
          expect(reference_sections.map(&:taxon).uniq).to eq [to_taxon]
          expect(reference_sections.map(&:position)).to eq [2, 3, 4]
        end
      end
    end

    describe 'validations' do
      let!(:from_taxon) { create :family }
      let!(:reference_section) { create :reference_section, taxon: from_taxon }

      context 'when `to_taxon` cannot have reference sections' do
        let!(:to_taxon) { create :species }

        it 'moves reference sections from a taxon to another' do
          expect { described_class[to_taxon, reference_sections: [reference_section]] }.
            to raise_error(described_class::ReferenceSectionsNotSupportedForRank)
        end
      end
    end
  end
end
