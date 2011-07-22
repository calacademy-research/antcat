require 'spec_helper'

describe Subspecies do

  it "has no statistics" do
    Subspecies.new.statistics.should be_nil
  end

  it "must have a species" do
    subspecies = Subspecies.new :name => 'Colobopsis'
    subspecies.should_not be_valid
    subspecies.species = Factory :species, :name => 'christi'
    subspecies.save!
    subspecies.reload.species.name.should == 'christi'
  end

  it "should have a subfamily" do
    species = Factory :species
    subspecies = Factory :subspecies, :species => species
    subspecies.subfamily.should == species.subfamily
  end

  it "should have a genus" do
    species = Factory :species
    subspecies = Factory :subspecies, :species => species
    subspecies.genus.should == species.genus
  end

  describe "Full name" do
    it "is the the genus, the species, and the subspecies name" do
      taxon = Factory :subspecies, :name => 'biggus', :species => Factory(:species, :name => 'emeryi', :genus => Factory(:genus, :name => 'Atta', :subfamily => Factory(:subfamily, :name => 'Dolichoderinae')))
      taxon.full_name.should == 'Atta emeryi biggus'
    end
  end

  describe "Full label" do
    it "is the the genus, the species, and the subspecies name" do
      taxon = Factory :subspecies, :name => 'biggus', :species => Factory(:species, :name => 'emeryi', :genus => Factory(:genus, :name => 'Atta', :subfamily => Factory(:subfamily, :name => 'Dolichoderinae')))
      taxon.full_label.should == '<i>Atta emeryi biggus</i>'
    end
  end

end
