# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::Operations::MoveItems do
  describe "#call" do
    describe 'moving history items' do
      let!(:from_protonym) { create :protonym }
      let!(:to_protonym) { create :protonym }
      let!(:history_item_1) { create :taxon_history_item, protonym: from_protonym }
      let!(:history_item_2) { create :taxon_history_item, protonym: from_protonym }
      let!(:history_item_3) { create :taxon_history_item, protonym: from_protonym }

      context 'when moving all history items belonging to a taxon' do
        let(:history_items) { [history_item_1, history_item_2, history_item_3] }

        it 'moves history items from a protonym to another with correct positions' do
          expect(history_items.map(&:protonym).uniq).to eq [from_protonym]
          expect(history_items.map(&:position)).to eq [1, 2, 3]

          described_class[to_protonym, history_items: history_items]

          history_items.map(&:reload)
          expect(history_items.map(&:protonym).uniq).to eq [to_protonym]
          expect(history_items.map(&:position)).to eq [1, 2, 3]
        end
      end

      context 'when moving some but not all items belonging to a protonym' do
        let!(:history_item_4) { create :taxon_history_item, protonym: from_protonym }

        let(:history_items) { [history_item_1, history_item_2, history_item_3] }

        it 'updates positions of history items that were not moved' do
          expect(history_items.map(&:protonym).uniq).to eq [from_protonym]
          expect(history_items.map(&:position)).to eq [1, 2, 3]
          expect(history_item_4.protonym).to eq from_protonym
          expect(history_item_4.position).to eq 4

          described_class[to_protonym, history_items: history_items]

          history_items.map(&:reload)
          expect(history_items.map(&:protonym).uniq).to eq [to_protonym]
          expect(history_items.map(&:position)).to eq [1, 2, 3]

          history_item_4.reload
          expect(history_item_4.protonym).to eq from_protonym
          expect(history_item_4.position).to eq 1
        end
      end

      context 'when `to_protonym` has history items of its own' do
        let(:history_items) { [history_item_1, history_item_2, history_item_3] }

        before do
          create :taxon_history_item, protonym: to_protonym
        end

        it 'places moved history items last in correct order' do
          expect(history_items.map(&:protonym).uniq).to eq [from_protonym]
          expect(history_items.map(&:position)).to eq [1, 2, 3]

          described_class[to_protonym, history_items: history_items]

          history_items.map(&:reload)
          expect(history_items.map(&:protonym).uniq).to eq [to_protonym]
          expect(history_items.map(&:position)).to eq [2, 3, 4]
        end
      end
    end
  end
end
