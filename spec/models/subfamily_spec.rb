require 'spec_helper'

describe Subfamily do

  it "should have tribes, which are its children" do
    subfamily = Factory :subfamily, :name => 'Myrmicinae'
    Factory :tribe, :name => 'Attini', :subfamily => subfamily
    Factory :tribe, :name => 'Dacetini', :subfamily => subfamily
    subfamily.tribes.map(&:name).should =~ ['Attini', 'Dacetini']
    subfamily.tribes.should == subfamily.children
  end

  it "should have genera" do
    myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
    dacetini = Factory :tribe, :name => 'Dacetini', :subfamily => myrmicinae
    Factory :genus, :name => 'Atta', :subfamily => myrmicinae, :tribe => Factory(:tribe, :name => 'Attini', :subfamily => myrmicinae)
    Factory :genus, :name => 'Acanthognathus', :subfamily => myrmicinae, :tribe => Factory(:tribe, :name => 'Dacetini', :subfamily => myrmicinae)
    myrmicinae.genera.map(&:name).should =~ ['Atta', 'Acanthognathus']
  end

  it "should have species" do
    subfamily = Factory :subfamily
    genus = Factory :genus, :subfamily => subfamily
    species = Factory :species, :genus => genus
    subfamily.should have(1).species
  end

  it "should have subspecies" do
    subfamily = Factory :subfamily
    genus = Factory :genus, :subfamily => subfamily
    species = Factory :species, :genus => genus
    subspecies = Factory :subspecies, :species => species
    subfamily.should have(1).subspecies
  end

  describe "Full name" do

    it "is just the name" do
      taxon = Factory :subfamily, :name => 'Dolichoderinae'
      taxon.full_name.should == 'Dolichoderinae'
    end

  end
end
