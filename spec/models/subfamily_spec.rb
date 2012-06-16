# coding: UTF-8
require 'spec_helper'

describe Subfamily do

  it "should have tribes, which are its children" do
    subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae')
    FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => subfamily
    FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Dacetini'), :subfamily => subfamily
    subfamily.tribes.map(&:name).map(&:to_s).should =~ ['Attini', 'Dacetini']
    subfamily.tribes.should == subfamily.children
  end

  it "should have genera" do
    myrmicinae = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae')
    dacetini = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Dacetini'), :subfamily => myrmicinae
    FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), :subfamily => myrmicinae, :tribe => FactoryGirl.create(:tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => myrmicinae)
    FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Acanthognathus'), :subfamily => myrmicinae, :tribe => FactoryGirl.create(:tribe, name: FactoryGirl.create(:name, name: 'Dacetini'), :subfamily => myrmicinae)
    myrmicinae.genera.map(&:name).map(&:to_s).should =~ ['Atta', 'Acanthognathus']
  end

  it "should have species" do
    subfamily = FactoryGirl.create :subfamily
    genus = FactoryGirl.create :genus, :subfamily => subfamily
    species = FactoryGirl.create :species, :genus => genus
    subfamily.should have(1).species
  end

  it "should have subspecies" do
    subfamily = FactoryGirl.create :subfamily
    genus = FactoryGirl.create :genus, subfamily: subfamily
    species = FactoryGirl.create :species, genus: genus
    subspecies = FactoryGirl.create :subspecies, genus: genus, species: species
    subfamily.should have(1).subspecies
  end

  describe "Name" do
    it "is just the name" do
      taxon = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
      taxon.name.to_s.should == 'Dolichoderinae'
    end
  end

  describe "Label" do
    it "is just the name" do
      taxon = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
      taxon.name.to_html.should == 'Dolichoderinae'
    end
  end

  describe "Statistics" do

    it "should handle 0 children" do
      subfamily = FactoryGirl.create :subfamily
      subfamily.statistics.should == {}
    end

    it "should handle 1 valid genus" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      subfamily.statistics.should == {:extant => {:genera => {'valid' => 1}}}
    end

    it "should handle 1 valid genus and 2 synonyms" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      2.times {FactoryGirl.create :genus, :subfamily => subfamily, :status => 'synonym'}
      subfamily.statistics.should == {:extant => {:genera => {'valid' => 1, 'synonym' => 2}}} 
    end

    it "should handle 1 valid genus with 2 valid species" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      2.times {FactoryGirl.create :species, :genus => genus, :subfamily => subfamily}
      subfamily.statistics.should == {:extant => {:genera => {'valid' => 1}, :species => {'valid' => 2}}}
    end

    it "should handle 1 valid genus with 2 valid species, one of which has a subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      subfamily.statistics.should == {extant: {genera: {'valid' => 1}, species: {'valid' => 2}, subspecies: {'valid' => 1}}}
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, subfamily: subfamily
      FactoryGirl.create :genus, subfamily: subfamily, fossil: true
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus), fossil: true
      subfamily.statistics.should == {
        extant: {genera: {'valid' => 1}, species: {'valid' => 3}, subspecies: {'valid' => 1}},
        :fossil => {genera: {'valid' => 1}, species: {'valid' => 1}, subspecies: {'valid' => 1}},
      }
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, subfamily: subfamily
      FactoryGirl.create :genus, subfamily: subfamily, fossil: true
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus), fossil: true
      subfamily.statistics.should == {
        extant: {genera: {'valid' => 1}, species: {'valid' => 3}, subspecies: {'valid' => 1}},
        fossil: {genera: {'valid' => 1}, species: {'valid' => 1}, subspecies: {'valid' => 1}},
      }
    end

  end

  describe "Importing" do
    it "should work" do
      reference = FactoryGirl.create :article_reference, :bolton_key_cache => 'Emery 1913a'
      subfamily = Subfamily.import(
        subfamily_name: 'Aneuretinae',
        fossil: true,
        protonym: {tribe_name: "Aneuretini",
                   authorship: [{author_names: ["Emery"], year: "1913a", pages: "6"}]},
        type_genus: {genus_name: 'Atta'},
        taxonomic_history: ["Aneuretinae as subfamily", "Aneuretini as tribe"]
      )
      
      subfamily.reload
      subfamily.name.to_s.should == 'Aneuretinae'
      subfamily.should_not be_invalid
      subfamily.should be_fossil
      subfamily.taxonomic_history_items.map(&:taxt).should == ['Aneuretinae as subfamily', 'Aneuretini as tribe']

      subfamily.type_name.to_s.should == 'Atta'
      subfamily.type_name.rank.should == 'genus'

      protonym = subfamily.protonym
      protonym.name.to_s.should == 'Aneuretini'

      authorship = protonym.authorship
      authorship.pages.should == '6'

      authorship.reference.should == reference
    end
  end

end
