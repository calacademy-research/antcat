require 'spec_helper'

describe Api::V1::NamesController do
  describe "GET index" do
    before do
      create_genus
      create_species 'Atta minor'
    end

    let!(:protonym_name) { create :species_name, name: 'Eciton minor' }

    it "gets all author names keys" do
      get :index

      expect(response.body.to_s).to include "Atta"
      expect(json_response.count).to eq 21
    end

    it "gets all author names keys (starts_at)" do
      get :index, params: { starts_at: protonym_name.id }

      expect(json_response[0]['species_name']['id']).to eq protonym_name.id
      expect(json_response.count).to eq 1
    end

    it 'returns HTTP 200' do
      get :index
      expect(response).to have_http_status :ok
    end
  end

  describe "GET show" do
    let!(:taxon) { create_genus }

    before { get :show, params: { id: taxon.name_id } }

    it "fetches a name" do
      expect(response.body.to_s).to include "Atta"
    end

    it 'returns HTTP 200' do
      expect(response).to have_http_status :ok
    end
  end
end
