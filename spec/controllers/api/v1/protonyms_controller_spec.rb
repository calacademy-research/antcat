require 'spec_helper'

describe Api::V1::ProtonymsController do
  describe "GET index" do
    before do
      create_genus
      create_species 'Atta minor'
      create :species_name, name: 'Eciton minor'
      get :index
    end

    it "gets all protonyms" do
      expect(json_response.count).to eq 7 # hmm
    end

    it 'returns HTTP 200' do
      expect(response).to have_http_status :ok
    end
  end

  describe "GET show" do
    let!(:taxon) { create_genus }

    before { get :show, params: { id: taxon.protonym_id } }

    it "fetches a protonym" do
      expect(response.body.to_s).to include taxon.protonym.id.to_s
    end

    it 'returns HTTP 200' do
      expect(response).to have_http_status :ok
    end
  end
end
