# frozen_string_literal: true

require 'rails_helper'

describe HistoryPresenter do
  subject(:presenter) { described_class.new(history_items) }

  let(:protonym) { create :protonym }
  let(:history_items) { protonym.history_items }

  describe "#grouped_items" do
    context 'without history items' do
      specify { expect(presenter.grouped_items).to eq [] }
    end

    describe 'grouping items into taxts' do
      context 'with `TAXT` items' do
        let!(:item_1) { create :history_item, :taxt, protonym: protonym }
        let!(:item_2) { create :history_item, :taxt, protonym: protonym }

        it 'does not group them' do
          expect(presenter.grouped_items.map(&:taxt)).to eq [
            item_1.taxt,
            item_2.taxt
          ]
        end
      end
    end

    describe 'sorting grouped taxts' do
      context 'with `TAXT` items' do
        let!(:item_1) { create :history_item, taxt: 'pos 3', protonym: protonym }
        let!(:item_2) { create :history_item, taxt: 'pos 1', protonym: protonym }
        let!(:item_3) { create :history_item, taxt: 'pos 2', protonym: protonym }

        before do
          item_1.update_columns(position: 3)
          item_2.update_columns(position: 1)
          item_3.update_columns(position: 2)
        end

        it 'sort taxt items by their position' do
          # Make sure positions are not auto updated for this spec.
          expect(history_items.pluck(:id, :position, :taxt)).to eq [
            [item_2.id, 1, 'pos 1'],
            [item_3.id, 2, 'pos 2'],
            [item_1.id, 3, 'pos 3']
          ]

          expect(presenter.grouped_items.map(&:taxt)).to eq [
            'pos 1',
            'pos 2',
            'pos 3'
          ]
        end
      end
    end
  end
end
