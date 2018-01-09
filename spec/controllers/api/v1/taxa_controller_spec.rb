require 'spec_helper'

describe Api::V1::TaxaController do
  describe "GET index" do
    it "gets all taxa greater than a given number" do
      create_genus
      create_species 'Not interesting'
      species = create_species 'Atta minor'
      create :species_name, name: 'Eciton minor'

      get :index, params: { starts_at: species.id }

      taxa = JSON.parse response.body
      expect(taxa[0]['species']['id']).to eq species.id
      expect(taxa.count).to eq 1
    end

    it "gets all taxa" do
      create_genus
      create_species 'Atta minor'
      create :species_name, name: 'Eciton minor'

      get :index

      expect(response.body.to_s).to include "Atta"
      taxa = JSON.parse response.body
      expect(taxa.count).to eq 7
    end

    it 'returns HTTP 200' do
      get :index
      expect(response).to have_http_status 200
    end
  end

  describe "GET show" do
    let!(:species) { create_species 'Atta minor maxus' }

    before { get :show, params: { id: species.id } }

    it "returns a single taxon entry" do
      parsed_species = JSON.parse response.body
      expect(response.body.to_s).to include "Atta"
      expect(parsed_species['species']['name_cache']).to eq "Atta minor maxus"
    end

    it 'returns HTTP 200' do
      expect(response).to have_http_status 200
    end
  end

  describe "GET search" do
    before { create_species 'Atta minor maxus' }

    it "searches for taxa" do
      get :search, params: { 'string' => 'maxus' }
      expect(response.body.to_s).to include "maxus"
    end

    it 'returns HTTP 200' do
      get :search, params: { 'string' => 'maxus' }
      expect(response).to have_http_status 200
    end

    context "when there are no search matches" do
      it 'returns HTTP 404' do
        get :search, params: { 'string' => 'maxuus' }
        expect(response).to have_http_status 404
      end
    end
  end
end
