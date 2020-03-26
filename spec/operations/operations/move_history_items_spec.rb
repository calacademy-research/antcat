# frozen_string_literal: true

require 'rails_helper'

describe Operations::MoveHistoryItems do
  subject(:operation) do
    described_class.new(
      to_taxon: to_taxon,
      history_items: history_items
    )
  end

  let!(:from_taxon) { create :family }
  let!(:to_taxon) { create :family }
  let!(:history_item) { create :taxon_history_item, taxon: from_taxon }
  let!(:history_items) { from_taxon.history_items }

  describe "#run" do
    describe "unsuccessful case" do
      before do
        history_item.update_columns(taxt: '') # Artificially create history item in an invalid state.
      end

      specify { expect(operation.run).to be_a_failure }

      it "returns errors" do
        expect(operation.run.context.errors).to eq ["Could not update history item ##{history_item.id}"]
      end

      it "does not modify the history item" do
        expect { operation.run }.to_not change { history_item.reload.attributes }
      end
    end

    describe "successful case" do
      specify { expect(operation.run).to be_a_success }

      it 'moves history items from a taxon to another' do
        expect { operation.run }.
          to change { history_item.reload.taxon }.from(from_taxon).to(to_taxon)
      end

      context 'when `to_taxon` has history items of its own' do
        before do
          create :taxon_history_item, taxon: to_taxon
        end

        it 'places moved history items last' do
          expect { operation.run }.
            to change { history_item.reload.position }.from(1).to(2)
        end
      end
    end
  end
end
