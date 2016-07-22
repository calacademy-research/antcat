require 'spec_helper'

describe Api::V1::TaxonHistoryItemsController do
  describe "getting data" do
    before do
      @found_reference = create :article_reference
      @missing_reference = create :missing_reference
      6.times { TaxonHistoryItem.create! taxt: "{ref #{@missing_reference.id}}" }
    end

    it "gets all taxon history items greater than a given number" do
      create_taxon
      species = create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'

      # Get index starting at four
      get :index, starts_at: 4
      expect(response.status).to eq 200

      taxon_history_item = JSON.parse response.body
      # since we want no ids less than 4, we should get a starting id at 4
      expect(taxon_history_item[0]['taxon_history_item']['id']).to eq 4
      expect(taxon_history_item.count).to eq 3
    end

    it "gets all taxon_history_items" do
      create_taxon
      species = create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'

      get :index, nil
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "position"

      taxon_history_items = JSON.parse response.body
      expect(taxon_history_items.count).to eq 6
    end
  end
end
