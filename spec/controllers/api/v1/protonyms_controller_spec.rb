require 'spec_helper'

describe Api::V1::ProtonymsController do
  describe "getting data" do
    it "fetches a protonym" do
      create_taxon
      get(:show, {'id' => '1'}, nil)
      expect(response.status).to eq(200)
      expect(response.body.to_s).to include("1")
    end


    it "gets all author names keys" do
      create_taxon
      species = create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'


      get(:index, nil)
      expect(response.status).to eq(200)


      author_names=JSON.parse(response.body)
      expect(author_names.count).to eq(7)
    end
  end
end
