require 'spec_helper'

describe Species do

  it "should have a genus" do
    genus = Factory :genus, :name => 'Atta'
    Factory :species, :name => 'championi', :genus => genus
    Species.find_by_name('championi').genus.should == genus
  end

  it "should have a subfamily" do
    genus = Factory :genus, :name => 'Atta'
    Factory :species, :name => 'championi', :genus => genus
    Species.find_by_name('championi').subfamily.should == genus.subfamily
  end

  it "doesn't need a genus" do
    Factory :species, :name => 'championi', :genus => nil
    Species.find_by_name('championi').genus.should be_nil
  end

  it "should have subspecies, which are its children" do
    species = Factory :species, :name => 'chilensis'
    Factory :subspecies, :name => 'robusta', :species => species
    Factory :subspecies, :name => 'saltensis', :species => species
    species = Species.find_by_name 'chilensis'
    species.subspecies.map(&:name).should =~ ['robusta', 'saltensis']
    species.children.should == species.subspecies
  end

  describe "Statistics" do

    it "should handle 0 children" do
      species = Factory :species
      species.statistics.should == {:subspecies => {}}
    end

    it "should handle 1 valid subspecies" do
      species = Factory :species
      subspecies = Factory :subspecies, :species => species
      species.statistics.should == {:subspecies => {'valid' => 1}}
    end

    it "should handle 1 valid subspecies and 2 synonyms" do
      species = Factory :species
      Factory :subspecies, :species => species
      2.times {Factory :subspecies, :species => species, :status => 'synonym'}
      species.statistics.should == {:subspecies => {'valid' => 1, 'synonym' => 2}}
    end

  end
end
