require 'spec_helper'

describe Api::V1::TaxaController do
  describe "getting data" do
    it "should get a single taxon entry" do
      # atta = create_genus 'Atta'
      # attacus = create_genus 'Attacus'
      # ratta = create_genus 'Ratta'
      # nylanderia = create_genus 'Nylanderia'
      species = create_species 'Atta minor maxus'
      # protonym_name = create_subspecies_name 'Eciton minor maxus'

      get :show, id: species.id
      expect(response.status).to eq 200
      parsed_species = JSON.parse response.body

      expect(response.body.to_s).to include "Atta"
      expect(parsed_species['species']['name_cache']).to eq "Atta minor maxus"
    end

    it "should search for a taxa" do
      create_species 'Atta minor maxus'

      get :search, {'string' => 'maxus'}, nil
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "maxus"
    end

    it "should report when there are no search matches" do
      create_species 'Atta minor maxus'

      get :search, {'string' => 'maxuus'}, nil
      expect(response.status).to eq 404
    end

    it "gets all taxa greater than a given number" do
      create_taxon
      create_species 'Not interesting'
      species = create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'

      # Get index
      get :index, starts_at: species.id
      expect(response.status).to eq 200

      taxa = JSON.parse response.body
      expect(taxa[0]['species']['id']).to eq species.id
      expect(taxa.count).to eq 1
    end

    it "gets all taxa" do
      create_taxon
      create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'

      get :index, nil
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "Atta"

      taxa = JSON.parse response.body
      expect(taxa.count).to eq 7
    end
  end
end
