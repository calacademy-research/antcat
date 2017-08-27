require 'spec_helper'

describe Api::V1::AuthorsController do
  describe "GET index" do
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

  describe "GET show" do
    it "fetches an author primary key" do
      barry_bolton = create :author
      bolton = create :author_name, name: 'Bolton', author: barry_bolton

      get :show, id: barry_bolton.id
      expect(response.status).to eq 200
      expect(response.body.to_s).to include barry_bolton.id.to_s
    end
  end
end
