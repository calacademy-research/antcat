require 'rails_helper'

describe Api::V1::NamesController do
  describe "GET index" do
    let!(:family_name) { create :family_name }
    let!(:species_name) { create :species_name }

    it "gets all names keys" do
      get :index

      expect(response.body.to_s).to include family_name.name
      expect(response.body.to_s).to include species_name.name
      expect(json_response.count).to eq 2
    end

    it "gets all names keys (starts_at)" do
      get :index, params: { starts_at: species_name.id }

      expect(json_response[0]['species_name']['id']).to eq species_name.id
      expect(json_response.count).to eq 1
    end

    specify { expect(get(:index)).to have_http_status :ok }
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
