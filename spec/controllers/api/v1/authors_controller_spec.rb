require 'spec_helper'

describe Api::V1::AuthorsController do
  describe "getting data" do
    it "fetches an author primary key" do
      barry_bolton = FactoryGirl.create :author
      bolton = FactoryGirl.create :author_name, name: 'Bolton', author: barry_bolton
      get(:show, {'id' => '1'}, nil)
      expect(response.status).to eq(200)
      expect(response.body.to_s).to include("1")
    end


    it "gets all author primary keys" do
      barry_bolton = FactoryGirl.create :author
      second = FactoryGirl.create :author

      get(:index, nil)
      expect(response.status).to eq(200)
      expect(response.body.to_s).to include("1")
      expect(response.body.to_s).to include("2")

      authors=JSON.parse(response.body)
      expect(authors.count).to eq(2)
    end
  end

end
