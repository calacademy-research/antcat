require 'spec_helper'

describe Api::V1::TaxaController do
  describe "GET index" do
    it "gets all taxa greater than a given number" do
      create_genus
      create_species 'Not interesting'
      species = create_species 'Atta minor'
      create_species_name 'Eciton minor'

      # Get index
      get :index, starts_at: species.id
      expect(response.status).to eq 200

      taxa = JSON.parse response.body
      expect(taxa[0]['species']['id']).to eq species.id
      expect(taxa.count).to eq 1
    end

    it "gets all taxa" do
      create_genus
      create_species 'Atta minor'
      create_species_name 'Eciton minor'

      get :index, nil
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "Atta"

      taxa = JSON.parse response.body
      expect(taxa.count).to eq 7
    end
  end

  describe "GET show" do
    it "should get a single taxon entry" do
      species = create_species 'Atta minor maxus'

      get :show, id: species.id
      expect(response.status).to eq 200
      parsed_species = JSON.parse response.body

      expect(response.body.to_s).to include "Atta"
      expect(parsed_species['species']['name_cache']).to eq "Atta minor maxus"
    end
  end

  describe "GET search" do
    it "should search for a taxa" do
      create_species 'Atta minor maxus'

      get :search, {'string' => 'maxus'}, nil
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "maxus"
    end

    it "reports when there are no search matches" do
      create_species 'Atta minor maxus'

      get :search, {'string' => 'maxuus'}, nil
      expect(response.status).to eq 404
    end
  end
end
