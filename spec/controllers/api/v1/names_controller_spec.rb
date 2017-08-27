require 'spec_helper'

describe Api::V1::NamesController do
  describe "GET index" do
    it "gets all author names keys" do
      create_genus
      create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'

      get :index, starts_at: protonym_name.id
      expect(response.status).to eq 200
      names = JSON.parse response.body
      expect(names[0]['species_name']['id']).to eq protonym_name.id

      expect(names.count).to eq 1

      get :index
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "Atta"

      names = JSON.parse response.body
      expect(names.count).to eq 22
    end
  end

  describe "GET show" do
    it "fetches a name" do
      taxon = create_genus

      get :show, id: taxon.name_id
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "Atta"
    end
  end
end
