# coding: UTF-8
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

  describe "Full label" do
    it "is just the name" do
      taxon = Factory :subfamily, :name => 'Dolichoderinae'
      taxon.full_label.should == 'Dolichoderinae'
    end
  end

  describe "Statistics" do

    it "should handle 0 children" do
      subfamily = Factory :subfamily
      subfamily.statistics.should == {}
    end

    it "should handle 1 valid genus" do
      subfamily = Factory :subfamily
      genus = Factory :genus, :subfamily => subfamily
      subfamily.statistics.should == {:extant => {:genera => {'valid' => 1}}}
    end

    it "should handle 1 valid genus and 2 synonyms" do
      subfamily = Factory :subfamily
      genus = Factory :genus, :subfamily => subfamily
      2.times {Factory :genus, :subfamily => subfamily, :status => 'synonym'}
      subfamily.statistics.should == {:extant => {:genera => {'valid' => 1, 'synonym' => 2}}} 
    end

    it "should handle 1 valid genus with 2 valid species" do
      subfamily = Factory :subfamily
      genus = Factory :genus, :subfamily => subfamily
      2.times {Factory :species, :genus => genus, :subfamily => subfamily}
      subfamily.statistics.should == {:extant => {:genera => {'valid' => 1}, :species => {'valid' => 2}}}
    end

    it "should handle 1 valid genus with 2 valid species, one of which has a subspecies" do
      subfamily = Factory :subfamily
      genus = Factory :genus, :subfamily => subfamily
      Factory :species, :genus => genus
      Factory :subspecies, :species => Factory(:species, :genus => genus)
      subfamily.statistics.should == {:extant => {:genera => {'valid' => 1}, :species => {'valid' => 2}, :subspecies => {'valid' => 1}}}
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = Factory :subfamily
      genus = Factory :genus, :subfamily => subfamily
      Factory :genus, :subfamily => subfamily, :fossil => true
      Factory :species, :genus => genus
      Factory :species, :genus => genus, :fossil => true
      Factory :subspecies, :species => Factory(:species, :genus => genus)
      Factory :subspecies, :species => Factory(:species, :genus => genus), :fossil => true
      subfamily.statistics.should == {
        :extant => {:genera => {'valid' => 1}, :species => {'valid' => 3}, :subspecies => {'valid' => 1}},
        :fossil => {:genera => {'valid' => 1}, :species => {'valid' => 1}, :subspecies => {'valid' => 1}},
      }
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = Factory :subfamily
      genus = Factory :genus, :subfamily => subfamily
      Factory :genus, :subfamily => subfamily, :fossil => true
      Factory :species, :genus => genus
      Factory :species, :genus => genus, :fossil => true
      Factory :subspecies, :species => Factory(:species, :genus => genus)
      Factory :subspecies, :species => Factory(:species, :genus => genus), :fossil => true
      subfamily.statistics.should == {
        :extant => {:genera => {'valid' => 1}, :species => {'valid' => 3}, :subspecies => {'valid' => 1}},
        :fossil => {:genera => {'valid' => 1}, :species => {'valid' => 1}, :subspecies => {'valid' => 1}},
      }
    end

  end
end
