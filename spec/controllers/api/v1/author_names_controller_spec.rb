require 'spec_helper'

describe Api::V1::AuthorNamesController do
  describe "GET index" do
    it "gets all author names keys" do
      create :author_name, name: 'Bolton'
      create :author_name, name: 'Fisher'

      get :index
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "Bolton"
      expect(response.body.to_s).to include "Fisher"

      author_names = JSON.parse response.body
      expect(author_names.count).to eq 2
    end
  end

  describe "GET show" do
    let!(:author_name) { create :author_name, name: 'Bolton' }

    it "fetches an author name" do
      get :show, id: author_name.id
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "Bolton"
    end
  end
end
