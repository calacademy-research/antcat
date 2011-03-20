require 'spec_helper'

describe Species do

  it "should have a genus" do
    genus = Factory :genus, :name => 'Atta'
    Factory :species, :name => 'championi', :genus => genus
    Species.find_by_name('championi').genus.should == genus
  end

  it "should have subspecies, which are its children" do
    species = Factory :species, :name => 'chilensis'
    Factory :subspecies, :name => 'robusta', :species => species
    Factory :subspecies, :name => 'saltensis', :species => species
    species = Species.find_by_name 'chilensis'
    species.subspecies.map(&:name).should =~ ['robusta', 'saltensis']
    species.children.should == species.subspecies
  end

end
