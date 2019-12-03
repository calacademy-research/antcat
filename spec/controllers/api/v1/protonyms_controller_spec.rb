require 'rails_helper'

describe Api::V1::ProtonymsController do
  describe "GET index" do
    before do
      create :family
      get :index
    end

    it "gets all protonyms" do
      expect(json_response.count).to eq 1
    end

    specify { expect(response).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:taxon) { create :family }

    before { get :show, params: { id: taxon.protonym_id } }

    it "fetches a protonym" do
      expect(response.body.to_s).to include taxon.protonym.id.to_s
    end

    specify { expect(response).to have_http_status :ok }
  end
end
