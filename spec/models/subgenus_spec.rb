# coding: UTF-8
require 'spec_helper'

describe Subgenus do

  it "must have a genus" do
    colobopsis = FactoryGirl.build :subgenus, name: FactoryGirl.create(:name, name: 'Colobopsis'), genus: nil
    colobopsis.should_not be_valid
    colobopsis.genus = FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Camponotus')

    colobopsis.save!
    colobopsis.reload.genus.name.to_s.should == 'Camponotus'
  end

  describe "Statistics" do
    it "should have none" do
      FactoryGirl.create(:subgenus).statistics.should be_nil
    end
  end

  describe "Species group descendants" do
    before do
      @subgenus = create_subgenus 'Subdolichoderus'
    end
    it "should return an empty array if there are none" do
      @subgenus.species_group_descendants.should == []
    end
    it "should return all the species" do
      species = create_species subgenus: @subgenus
      @subgenus.species_group_descendants.should == [species]
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

      subgenus.name.to_s.should == 'Atta (Subatta)'
      subgenus.name.epithet.should == 'Subatta'
      subgenus.should_not be_invalid
      subgenus.should be_fossil
      subgenus.genus.should == genus
      genus.subgenera.map(&:id).should == [subgenus.id]
      subgenus.history_items.map(&:taxt).should == ['Atta as subgenus', 'Atta as species']
      subgenus.type_taxt.should == ', by monotypy'

      protonym = subgenus.protonym
      protonym.name.to_s.should == 'Atta (Subatta)'

      authorship = protonym.authorship
      authorship.pages.should == '124'

      authorship.reference.should == reference

      subgenus.reload
      subgenus.type_name.to_s.should == 'Atta major'
      subgenus.type_name.rank.should == 'species'
    end

  end

end
