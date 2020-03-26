# frozen_string_literal: true

require 'rails_helper'

describe CleanupTaxon do
  describe '#combination_in_according_to_history_items' do
    let!(:obsolete_genus) { create :genus }
    let!(:taxon) { create :species }

    context "when taxon has no 'Combination in' history item" do
      specify { expect(taxon.combination_in_according_to_history_items).to eq [] }
    end

    context "when taxon has 'Combination in' history items" do
      before do
        create :taxon_history_item, taxon: taxon, taxt: "Combination in {tax #{obsolete_genus.id}}"
      end

      specify { expect(taxon.combination_in_according_to_history_items).to eq [obsolete_genus] }
    end
  end
end
