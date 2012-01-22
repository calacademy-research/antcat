# coding: UTF-8
require 'spec_helper'

describe Genus do

  it "should have a tribe" do
    attini = Factory :tribe, :name => 'Attini', :subfamily => Factory(:subfamily, :name => 'Myrmicinae')
    Factory :genus, :name => 'Atta', :tribe => attini
    Genus.find_by_name('Atta').tribe.should == attini
  end

  it "should have species, which are its children" do
    atta = Factory :genus, :name => 'Atta'
    Factory :species, :name => 'robusta', :genus => atta
    Factory :species, :name => 'saltensis', :genus => atta
    atta = Genus.find_by_name('Atta')
    atta.species.map(&:name).should =~ ['robusta', 'saltensis']
    atta.children.should == atta.species
  end

  it "should have subspecies" do
    genus = Factory :genus
    Factory :subspecies, :species => Factory(:species, :genus => genus)
    genus.should have(1).subspecies
  end

  it "should have subgenera" do
    atta = Factory :genus, :name => 'Atta'
    Factory :subgenus, :name => 'robusta', :genus => atta
    Factory :subgenus, :name => 'saltensis', :genus => atta
    atta = Genus.find_by_name('Atta')
    atta.subgenera.map(&:name).should =~ ['robusta', 'saltensis']
  end

  describe "Full name" do

    it "is the genus name" do
      taxon = Factory :genus, :name => 'Atta', :subfamily => Factory(:subfamily, :name => 'Dolichoderinae')
      taxon.full_name.should == 'Atta'
    end

    it "is just the genus name if there is no subfamily" do
      taxon = Factory :genus, :name => 'Atta', :subfamily => nil
      taxon.full_name.should == 'Atta'
    end

  end

  describe "Full label" do

    it "is the genus name" do
      taxon = Factory :genus, :name => 'Atta', :subfamily => Factory(:subfamily, :name => 'Dolichoderinae')
      taxon.full_label.should == '<i>Atta</i>'
    end

    it "is just the genus name if there is no subfamily" do
      taxon = Factory :genus, :name => 'Atta', :subfamily => nil
      taxon.full_label.should == '<i>Atta</i>'
    end

  end

  describe "Statistics" do

    it "should handle 0 children" do
      genus = Factory :genus
      genus.statistics.should == {}
    end

    it "should handle 1 valid species" do
      genus = Factory :genus
      species = Factory :species, :genus => genus
      genus.statistics.should == {:extant => {:species => {'valid' => 1}}}
    end

    it "should handle 1 valid species and 2 synonyms" do
      genus = Factory :genus
      Factory :species, :genus => genus
      2.times {Factory :species, :genus => genus, :status => 'synonym'}
      genus.statistics.should == {:extant => {:species => {'valid' => 1, 'synonym' => 2}}}
    end

    it "should handle 1 valid species with 2 valid subspecies" do
      genus = Factory :genus
      species = Factory :species, :genus => genus
      2.times {Factory :subspecies, :species => species}
      genus.statistics.should == {:extant => {:species => {'valid' => 1}, :subspecies => {'valid' => 2}}}
    end

    it "should be able to differentiate extinct species and subspecies" do
      genus = Factory :genus
      species = Factory :species, :genus => genus
      fossil_species = Factory :species, :genus => genus, :fossil => true
      Factory :subspecies, :species => species, :fossil => true
      Factory :subspecies, :species => species
      Factory :subspecies, :species => fossil_species, :fossil => true
      genus.statistics.should == {
        :extant => {:species => {'valid' => 1}, :subspecies => {'valid' => 1}},
        :fossil => {:species => {'valid' => 1}, :subspecies => {'valid' => 2}},
      }
    end

    it "should be able to differentiate extinct species and subspecies" do
      genus = Factory :genus
      species = Factory :species, :genus => genus
      fossil_species = Factory :species, :genus => genus, :fossil => true
      Factory :subspecies, :species => species, :fossil => true
      Factory :subspecies, :species => species
      Factory :subspecies, :species => fossil_species, :fossil => true
      genus.statistics.should == {
        :extant => {:species => {'valid' => 1}, :subspecies => {'valid' => 1}},
        :fossil => {:species => {'valid' => 1}, :subspecies => {'valid' => 2}},
      }
    end

  end

  describe "Without subfamily" do
    it "should just return the genera with no subfamily" do
      cariridris = Factory :genus, :subfamily => nil
      atta = Factory :genus
      Genus.without_subfamily.all.should == [cariridris]
    end
  end

  describe "Without tribe" do
    it "should just return the genera with no tribe" do
      tribe = Factory :tribe
      cariridris = Factory :genus, :tribe => tribe, :subfamily => tribe.subfamily
      atta = Factory :genus, :subfamily => tribe.subfamily, :tribe => nil
      Genus.without_tribe.all.should == [atta]
    end
  end

  describe "Siblings" do

    it "should return itself when there are no others" do
      Factory :genus
      tribe = Factory :tribe
      genus = Factory :genus, :tribe => tribe, :subfamily => tribe.subfamily
      genus.siblings.should == [genus]
    end

    it "should return itself and its tribe's other genera" do
      Factory :genus
      tribe = Factory :tribe
      genus = Factory :genus, :tribe => tribe, :subfamily => tribe.subfamily
      another_genus = Factory :genus, :tribe => tribe, :subfamily => tribe.subfamily
      genus.siblings.should =~ [genus, another_genus]
    end

    it "when there's no subfamily, should return all the genera with no subfamilies" do
      Factory :genus
      genus = Factory :genus, :subfamily => nil, :tribe => nil
      another_genus = Factory :genus, :subfamily => nil, :tribe => nil
      genus.siblings.should =~ [genus, another_genus]
    end

    it "when there's no tribe, return the other genera in its subfamily without tribes" do
      subfamily = Factory :subfamily
      tribe = Factory :tribe, :subfamily => subfamily
      Factory :genus, :tribe => tribe, :subfamily => subfamily
      genus = Factory :genus, :subfamily => subfamily, :tribe => nil
      another_genus = Factory :genus, :subfamily => subfamily, :tribe => nil
      genus.siblings.should =~ [genus, another_genus]
    end

  end

  describe "Importing" do

    it "should work" do
      subfamily = Factory :subfamily
      reference = Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
      genus = Genus.import(
        subfamily: subfamily,
        name: 'Atta',
        fossil: true,
        protonym: {genus_name: "Atta",
                   authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]},
        type_species: {genus_name: 'Atta', species_epithet: 'major',
                          texts: [{text: [{phrase: ', by monotypy'}]}]},
        taxonomic_history: ["Atta as genus", "Atta as species"]
      ).reload
      genus.name.should == 'Atta'
      genus.should_not be_invalid
      genus.should be_fossil
      genus.subfamily.should == subfamily
      genus.taxonomic_history_items.map(&:taxt).should == ['Atta as genus', 'Atta as species']
      genus.type_taxon_taxt.should == ', by monotypy'

      protonym = genus.protonym
      protonym.name.should == 'Atta'

      authorship = protonym.authorship
      authorship.pages.should == '124'

      authorship.reference.should == reference
    end

    it "save the subgenus part correctly" do
      Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
      genus = Genus.import({
        name: 'Atta',
        protonym: {genus_name: "Atta", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]},
        type_species: {genus_name: 'Atta', subgenus_epithet: 'Solis', species_epithet: 'major',
                          texts: [{text: [{phrase: ', by monotypy'}]}]},
        taxonomic_history: [],
      })
      ForwardReference.fixup
      genus.reload.type_taxon_name.should == 'Atta (Solis) major'
    end

    it "should not mind if there's no type" do
      reference = Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
      genus = Genus.import({
        :name => 'Atta',
        :protonym => {
          :name => "Atta",
          :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
        },
        :taxonomic_history => ["Atta as genus", "Atta as species"]
      }).reload
      ForwardReference.fixup
      genus.type_taxon.should be_nil
    end

    it "should make sure the type-species is fixed up to point to the genus and not just to any genus with the same name" do
      reference = Factory :article_reference, :bolton_key_cache => 'Latreille 1809'

      genus = Genus.import({
        :name => 'Myrmicium',
        :protonym => {
          :name => "Myrmicium",
          :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
        },
        :type_species => {:genus_name => 'Myrmicium', :species_epithet => 'heeri'},
        :taxonomic_history => []
      })
      ForwardReference.fixup
      genus.reload.type_taxon.genus.should == genus
    end

  end

  describe "Creating from a fixup" do
    before do
      @subfamily = Factory :subfamily, name: 'Dolichoderinae'
    end
    it "should create the genus, and use the passed-in subfamily" do
      Progress.should_receive(:log).with("FIXUP created genus Atta")
      genus = Genus.create_from_fixup subfamily_id: @subfamily.id, name: 'Atta', fossil: true
      genus.reload.name.should == 'Atta'
      genus.should_not be_invalid
      genus.should be_fossil
      genus.subfamily.should == @subfamily
    end

    it "should find an existing genus" do
      existing_genus = Factory :genus, name: 'Atta', subfamily: @subfamily, status: 'valid'
      genus = Genus.create_from_fixup subfamily_id: @subfamily.id, name: 'Atta'
      genus.reload.should == existing_genus
    end
  end
end
