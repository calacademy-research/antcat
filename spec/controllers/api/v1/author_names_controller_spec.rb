require 'spec_helper'

describe Api::V1::AuthorNamesController do
  describe "getting data" do
    it "fetches an author name" do
      create :author_name, name: 'Bolton'

      get :show, id: 1
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "Bolton"
    end

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
end
