require 'spec_helper'

describe Api::V1::CitationsController do
  before do
    create :genus
  end

  let!(:species) { create_species 'Atta minor' }

  describe "GET index" do
    # TODO depends on being run before any other specs.
    xit "gets all citations greater than a given number" do
      get :index, params: { starts_at: species.id } # Get index starting at four.

      # Since we want no ids less than 4, we should get a starting id at 4.
      expect(json_response[0]['citation']['id']).to eq species.id
      expect(json_response.count).to eq 1
    end

    it "gets all citations" do
      get :index

      expect(response.body.to_s).to include "pages"
      expect(json_response.count).to eq 7
    end

    it 'returns HTTP 200' do
      get :index
      expect(response).to have_http_status :ok
    end
  end
end
