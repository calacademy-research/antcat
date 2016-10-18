require 'spec_helper'

describe Api::V1::ProtonymsController do
  describe "getting data" do
    it "fetches a protonym" do
      taxon = create_taxon

      get :show, id: taxon.protonym_id
      expect(response.status).to eq 200
      expect(response.body.to_s).to include taxon.id.to_s
    end

    it "gets all protonyms" do
      create_taxon
      create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'

      get :index
      expect(response.status).to eq 200

      author_names = JSON.parse response.body
      expect(author_names.count).to eq 7
    end
  end
end
