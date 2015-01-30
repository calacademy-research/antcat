# coding: UTF-8
require 'spec_helper'

describe Subgenus do

  it "must have a genus" do
    colobopsis = FactoryGirl.build :subgenus, name: FactoryGirl.create(:name, name: 'Colobopsis'), genus: nil
    expect(colobopsis).not_to be_valid
    colobopsis.genus = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Camponotus')

    colobopsis.save!
    expect(colobopsis.reload.genus.name.to_s).to eq('Camponotus')
  end

  describe "Statistics" do
    it "should have none" do
      expect(FactoryGirl.create(:subgenus).statistics).to be_nil
    end
  end

  describe "Species group descendants" do
    before do
      @subgenus = create_subgenus 'Subdolichoderus'
    end
    it "should return an empty array if there are none" do
      expect(@subgenus.species_group_descendants).to eq([])
    end
    it "should return all the species" do
      species = create_species subgenus: @subgenus
      expect(@subgenus.species_group_descendants).to eq([species])
    end
  end

  describe "Importing" do
    it "should work" do
      genus = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta')
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Latreille 1809'

      subgenus = Subgenus.import(
        genus: genus,
        subgenus_epithet: 'Subatta',
        fossil: true,
        protonym: {genus: genus, subgenus_epithet: "Subatta",
                   authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]},
        type_species: {genus_name: 'Atta', subgenus_name: 'Subatta', species_epithet: 'major',
                          texts: [{text: [{phrase: ', by monotypy'}]}]},
        history: ["Atta as subgenus", "Atta as species"]
      )

      expect(subgenus.name.to_s).to eq('Atta (Subatta)')
      expect(subgenus.name.epithet).to eq('Subatta')
      expect(subgenus).not_to be_invalid
      expect(subgenus).to be_fossil
      expect(subgenus.genus).to eq(genus)
      expect(genus.subgenera.map(&:id)).to eq([subgenus.id])
      expect(subgenus.history_items.map(&:taxt)).to eq(['Atta as subgenus', 'Atta as species'])
      expect(subgenus.type_taxt).to eq(', by monotypy')

      protonym = subgenus.protonym
      expect(protonym.name.to_s).to eq('Atta (Subatta)')

      authorship = protonym.authorship
      expect(authorship.pages).to eq('124')

      expect(authorship.reference).to eq(reference)

      subgenus.reload
      expect(subgenus.type_name.to_s).to eq('Atta major')
      expect(subgenus.type_name.rank).to eq('species')
    end

  end

end
