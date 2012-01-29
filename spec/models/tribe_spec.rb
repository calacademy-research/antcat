# coding: UTF-8
require 'spec_helper'

describe Tribe do

  it "should have a subfamily" do
    subfamily = Factory :subfamily, :name => 'Myrmicinae'
    Factory :tribe, :name => 'Attini', :subfamily => subfamily
    Tribe.find_by_name('Attini').subfamily.should == subfamily
  end

  it "should have genera, which are its children" do
    attini = Factory :tribe, :name => 'Attini'
    Factory :genus, :name => 'Acromyrmex', :tribe => attini
    Factory :genus, :name => 'Atta', :tribe => attini
    attini.genera.map(&:name).should =~ ['Atta', 'Acromyrmex']
    attini.children.should == attini.genera
  end

  it "should have as its full name just its name" do
    taxon = Factory :tribe, :name => 'Attini', :subfamily => Factory(:subfamily, :name => 'Myrmicinae')
    taxon.full_name.should == 'Attini'
  end

  it "should have as its full label, just its name" do
    taxon = Factory :tribe, :name => 'Attini', :subfamily => Factory(:subfamily, :name => 'Myrmicinae')
    taxon.full_label.should == 'Attini'
  end

  describe "Siblings" do

    it "should return itself and its subfamily's other tribes" do
      Factory :tribe
      subfamily = Factory :subfamily
      tribe = Factory :tribe, :subfamily => subfamily
      another_tribe = Factory :tribe, :subfamily => subfamily
      tribe.siblings.should =~ [tribe, another_tribe]
    end

  end

  describe "Statistics" do
    it "should have none" do
      Factory(:tribe).statistics.should be_nil
    end
  end

  describe "Importing" do
    it "should work" do
      reference = Factory :article_reference, :bolton_key_cache => 'Emery 1913a'
      tribe = Tribe.import(
        name: 'Aneuretini',
        fossil: true,
        protonym: {tribe_name: "Aneuretini",
                   authorship: [{author_names: ["Emery"], year: "1913a", pages: "6"}]},
        type_genus: {genus_name: 'Atta'},
        taxonomic_history: ["Aneuretini history"]
      )
      
      ForwardReference.fixup
      tribe.reload

      tribe.name.should == 'Aneuretini'
      tribe.should_not be_invalid
      tribe.should be_fossil
      tribe.taxonomic_history_items.map(&:taxt).should == ['Aneuretini history']

      genus = tribe.type_taxon
      genus.name.should == 'Atta'

      protonym = tribe.protonym
      protonym.name.should == 'Aneuretini'

      authorship = protonym.authorship
      authorship.pages.should == '6'

      authorship.reference.should == reference
    end
  end

end
