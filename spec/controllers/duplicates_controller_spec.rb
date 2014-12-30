require 'spec_helper'


describe DuplicatesController do

  describe "find a duplicate case" do

    it "Should find a secondary_junior_homonym match for same name" do
      @user = FactoryGirl.create :user
      species_epithet = "species a"
      genus_a = create_genus "GA"
      species_a = create_species species_epithet, genus: genus_a, status: Status['original combination'].to_s
      genus_b = create_genus "GB"
      species_b = create_species species_epithet, genus: genus_b, status: Status['valid'].to_s
      sign_in @user
      get :show, parent_id: genus_a.id, previous_combination_id: species_b.id, rank_to_create: 'species'
      expect(response.status).to eq(200)
      taxa=JSON.parse(response.body)
      expect(taxa).to have(1).item
      expect(taxa[0]['species']['name_cache']).to eq species_epithet
      expect(taxa[0]['species']['duplicate_type']).to eq 'secondary_junior_homonym'
    end

    it "Should find a return_to_original match for same protonym" do
      @user = FactoryGirl.create :user
      species_epithet = "species a"
      genus_a = create_genus "GA"
      species_a = create_species species_epithet, genus: genus_a, status: Status['original combination'].to_s
      genus_b = create_genus "GB"
      species_b = create_species species_epithet, genus: genus_b, status: Status['valid'].to_s, protonym_id: species_a.id
      sign_in @user
      get :show, parent_id: genus_a.id, previous_combination_id: species_b.id, rank_to_create: 'species'
      expect(response.status).to eq(200)
      taxa=JSON.parse(response.body)
      expect(taxa).to have(1).item
      expect(taxa[0]['species']['name_cache']).to eq species_epithet
      expect(taxa[0]['species']['duplicate_type']).to eq 'return_to_original'
      #expect(asset['connection_id']).to eq(@connection1['id'])
      #expect(response.body).to include ("Asset id 999 not found")
    end

    it "Should find no matches for same protonym distinct epithet" do
      @user = FactoryGirl.create :user
      species_epithet = "species a"
      genus_a = create_genus "GA"
      species_a = create_species species_epithet, genus: genus_a, status: Status['original combination'].to_s
      genus_b = create_genus "GB"
      species_b = create_species species_epithet+"boo", genus: genus_b, status: Status['valid'].to_s, protonym_id: species_a.id
      sign_in @user
      get :show, parent_id: genus_a.id, previous_combination_id: species_b.id, rank_to_create: 'species'
      expect(response.status).to eq(204)

    end
  end

end