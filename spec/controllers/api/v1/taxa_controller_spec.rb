require 'spec_helper'

describe Api::V1::TaxaController do
  describe "GET index" do
    it "gets all taxa greater than a given number" do
      create :genus
      create :species
      species = create :species

      get :index, params: { starts_at: species.id }

      expect(json_response[0]['species']['id']).to eq species.id
      expect(json_response.count).to eq 1
    end

    it "gets all taxa" do
      genus = create :genus

      get :index

      expect(response.body.to_s).to include genus.name.name
      expect(json_response.count).to eq 3 # TODO.
    end

    it 'returns HTTP 200' do
      get :index
      expect(response).to have_http_status :ok
    end
  end

  describe "GET show" do
    let!(:species) { create :species }

    before { get :show, params: { id: species.id } }

    it "returns a single taxon entry" do
      expect(response.body.to_s).to include "Atta"
      expect(json_response['species']['name_cache']).to eq species.name.name
    end

    specify { expect(response).to have_http_status :ok }
  end

  describe "GET search" do
    before { create_species 'Atta minor maxus' }

    it "searches for taxa" do
      get :search, params: { string: 'maxus' }
      expect(response.body.to_s).to include "maxus"
    end

    it 'returns HTTP 200' do
      get :search, params: { string: 'maxus' }
      expect(response).to have_http_status :ok
    end

    context "when there are no search matches" do
      it 'returns HTTP 404' do
        get :search, params: { string: 'maxuus' }
        expect(response).to have_http_status :not_found
      end
    end
  end
end
