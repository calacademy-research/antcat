require 'spec_helper'

describe Api::V1::NamesController do
  describe "GET index" do
    before do
      create :family
    end

    let!(:species_name) { create :species_name }

    it "gets all author names keys" do
      get :index

      expect(response.body.to_s).to include "Atta"
      expect(json_response.count).to eq 3 # TODO.
    end

    it "gets all author names keys (starts_at)" do
      get :index, params: { starts_at: species_name.id }

      expect(json_response[0]['species_name']['id']).to eq species_name.id
      expect(json_response.count).to eq 1
    end

    it 'returns HTTP 200' do
      get :index
      expect(response).to have_http_status :ok
    end
  end

  describe "GET show" do
    let!(:taxon) { create :family }

    before { get :show, params: { id: taxon.name_id } }

    it "fetches a name" do
      expect(response.body.to_s).to include taxon.name.name
    end

    specify { expect(response).to have_http_status :ok }
  end
end
