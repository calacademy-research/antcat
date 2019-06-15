require 'spec_helper'

describe Taxa::Operations::MoveItems do
  describe "#call" do
    let!(:from_taxon) { create :family }
    let!(:to_taxon) { create :family }
    let!(:history_item) { create :taxon_history_item, taxon: from_taxon }

    it 'moves history items from a taxon to antoher' do
      expect { described_class[to_taxon, [history_item]] }.
        to change { history_item.reload.taxon }.from(from_taxon).to(to_taxon)
    end

    context 'when `to_taxon` has history items of its own' do
      let!(:old_history_item) { create :taxon_history_item, taxon: to_taxon }

      it 'places moved history items last' do
        expect { described_class[to_taxon, [history_item]] }.
          to change { history_item.reload.position }.from(1).to(2)
      end
    end
  end
end
