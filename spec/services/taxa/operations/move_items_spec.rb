# frozen_string_literal: true

require 'rails_helper'

describe Taxa::Operations::MoveItems do
  describe "#call" do
    describe 'moving history items' do
      let!(:from_taxon) { create :any_taxon }
      let!(:to_taxon) { create :any_taxon }
      let!(:history_item) { create :taxon_history_item, taxon: from_taxon }

      it 'moves history items from a taxon to another' do
        expect { described_class[to_taxon, history_items: [history_item]] }.
          to change { history_item.reload.taxon }.from(from_taxon).to(to_taxon)
      end

      context 'when `to_taxon` has history items of its own' do
        before do
          create :taxon_history_item, taxon: to_taxon
        end

        it 'places moved history items last' do
          expect { described_class[to_taxon, history_items: [history_item]] }.
            to change { history_item.reload.position }.from(1).to(2)
        end
      end
    end
  end
end
