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
      taxon.full_name.should == '<i>Atta</i>'
    end

    it "is just the genus name if there is no subfamily" do
      taxon = Factory :genus, :name => 'Atta', :subfamily => nil
      taxon.full_name.should == '<i>Atta</i>'
    end

  end

  describe "Statistics" do

    it "should handle 0 children" do
      genus = Factory :genus
      genus.statistics.should == {:species => {}, :subspecies => {}}
    end

    it "should handle 1 valid species" do
      genus = Factory :genus
      species = Factory :species, :genus => genus
      genus.statistics.should == {:species => {'valid' => 1}, :subspecies => {}}
    end

    it "should handle 1 valid species and 2 synonyms" do
      genus = Factory :genus
      Factory :species, :genus => genus
      2.times {Factory :species, :genus => genus, :status => 'synonym'}
      genus.statistics.should == {:species => {'valid' => 1, 'synonym' => 2}, :subspecies => {}}
    end

    it "should handle 1 valid species with 2 valid subspecies" do
      genus = Factory :genus
      species = Factory :species, :genus => genus
      2.times {Factory :subspecies, :species => species}
      genus.statistics.should == {:species => {'valid' => 1}, :subspecies => {'valid' => 2}}
    end

  end

  describe "Without subfamily" do
    it "should just return the genera with no subfamily" do
      cariridris = Factory :genus, :subfamily => nil
      atta = Factory :genus
      Genus.without_subfamily.all.should == [cariridris]
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

  end
end
