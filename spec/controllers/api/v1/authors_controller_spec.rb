require 'spec_helper'

describe Api::V1::AuthorsController do
  describe "getting data" do
    it "fetches an author primary key" do
      barry_bolton = create :author
      bolton = create :author_name, name: 'Bolton', author: barry_bolton

      get :show, id: bolton.id
      expect(response.status).to eq 200
      expect(response.body.to_s).to include bolton.id.to_s
    end

    it "gets all author primary keys" do
      barry_bolton = create :author
      second = create :author

      get :index
      expect(response.status).to eq 200
      expect(response.body.to_s).to include barry_bolton.id.to_s
      expect(response.body.to_s).to include second.id.to_s

      authors = JSON.parse response.body
      expect(authors.count).to eq 2
    end
  end
end
