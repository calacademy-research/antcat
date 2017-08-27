require 'spec_helper'

describe Api::V1::ProtonymsController do
  describe "GET index" do
    it "gets all protonyms" do
      create_genus
      create_species 'Atta minor'
      create_species_name 'Eciton minor'

      get :index
      expect(response.status).to eq 200

      author_names = JSON.parse response.body
      expect(author_names.count).to eq 7 # hmm
    end
  end

  describe "GET show" do
    it "fetches a protonym" do
      taxon = create_genus

      get :show, id: taxon.protonym_id
      expect(response.status).to eq 200
      expect(response.body.to_s).to include taxon.protonym.id.to_s
    end
  end
end
