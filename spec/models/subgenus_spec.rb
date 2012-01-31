# coding: UTF-8
require 'spec_helper'

describe Subgenus do

  it "must have a genus" do
    colobopsis = Subgenus.new :name => 'Colobopsis'
    colobopsis.should_not be_valid
    colobopsis.genus = Factory :genus, :name => 'Camponotus'
    colobopsis.save!
    colobopsis.reload.genus.name.should == 'Camponotus'
  end

  describe "Statistics" do
    it "should have none" do
      Factory(:subgenus).statistics.should be_nil
    end
  end

  describe "Importing" do
    it "should work" do
      genus = Factory :genus
      reference = Factory :article_reference, :bolton_key_cache => 'Latreille 1809'

      subgenus = Subgenus.import(
        genus: genus,
        name: 'Atta',
        fossil: true,
        protonym: {subgenus_name: "Atta",
                   authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]},
        type_species: {subgenus_name: 'Atta', species_epithet: 'major',
                          texts: [{text: [{phrase: ', by monotypy'}]}]},
        taxonomic_history: ["Atta as subgenus", "Atta as species"]
      )

      subgenus.name.should == 'Atta'
      subgenus.should_not be_invalid
      subgenus.should be_fossil
      subgenus.genus.should == genus
      genus.subgenera.map(&:id).should == [subgenus.id]
      #subgenus.subfamily.should == genus.subfamily
      subgenus.taxonomic_history_items.map(&:taxt).should == ['Atta as subgenus', 'Atta as species']
      subgenus.type_taxon_taxt.should == ', by monotypy'

      protonym = subgenus.protonym
      protonym.name.should == 'Atta'

      authorship = protonym.authorship
      authorship.pages.should == '124'

      authorship.reference.should == reference

      ForwardReference.fixup

      subgenus.reload
      subgenus.type_taxon_name.should == 'Atta major'
      subgenus.type_taxon_rank.should == 'species'
    end

  end
end
