require 'spec_helper'

describe Api::V1::CitationsController do
  before do
    create_genus
    create :species_name, name: 'Eciton minor'
  end

  let!(:species) { create_species 'Atta minor' }

  describe "GET index" do
    it "gets all citations greater than a given number" do
      get :index, starts_at: species.id # Get index starting at four.

      # Since we want no ids less than 4, we should get a starting id at 4.
      citations = JSON.parse response.body
      expect(citations[0]['citation']['id']).to eq species.id
      expect(citations.count).to eq 1
    end

    it "gets all citations" do
      get :index

      expect(response.body.to_s).to include "pages"
      citations = JSON.parse response.body
      expect(citations.count).to eq 7
    end

    it 'returns HTTP 200' do
      get :index
      expect(response).to have_http_status 200
    end
  end
end
