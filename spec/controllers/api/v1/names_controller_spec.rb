require 'spec_helper'

describe Api::V1::NamesController do
  describe "getting data" do
    it "fetches a name" do
      create_taxon
      get(:show, {'id' => '1'}, nil)
      expect(response.status).to eq(200)
      expect(response.body.to_s).to include("Atta")
    end


    it "gets all author names keys" do
      create_taxon
      species = create_species 'Atta minor'
      protonym_name = create_species_name 'Eciton minor'


      get(:index, starts_at: 4)
      expect(response.status).to eq(200)
      names=JSON.parse(response.body)
      expect(names[0]['genus_name']['id']).to eq(4)

      expect(names.count).to eq(18)

      get(:index, nil)
      expect(response.status).to eq(200)
      expect(response.body.to_s).to include("Atta")


      names=JSON.parse(response.body)
      expect(names.count).to eq(21)
    end
  end
end