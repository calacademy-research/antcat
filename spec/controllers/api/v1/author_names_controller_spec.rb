require 'spec_helper'

describe Api::V1::AuthorNamesController do
  describe "getting data" do
    it "fetches an author name" do
      barry_bolton = FactoryGirl.create :author
      bolton = FactoryGirl.create :author_name, name: 'Bolton', author: barry_bolton
      get(:show, {'id' => '1'}, nil)
      expect(response.status).to eq(200)
      expect(response.body.to_s).to include("Bolton")
    end


    it "gets all author names keys" do
      barry_bolton = FactoryGirl.create :author
      second = FactoryGirl.create :author
      bolton = FactoryGirl.create :author_name, name: 'Bolton', author: barry_bolton
      bolton = FactoryGirl.create :author_name, name: 'Fisher', author: second

      get(:index, nil)
      expect(response.status).to eq(200)
      expect(response.body.to_s).to include("Bolton")
      expect(response.body.to_s).to include("Fisher")

      author_names=JSON.parse(response.body)
      expect(author_names.count).to eq(2)
    end
  end

end
