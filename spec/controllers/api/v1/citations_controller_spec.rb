require 'spec_helper'

describe Api::V1::CitationsController do
  let!(:species) { create :species }

  describe "GET index" do
    it "gets all citations" do
      get :index

      expect(response.body.to_s).to include "pages"
      expect(json_response.count).to eq 4 # TODO.
    end

    it 'returns HTTP 200' do
      get :index
      expect(response).to have_http_status :ok
    end
  end
end
