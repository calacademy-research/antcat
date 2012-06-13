# coding: UTF-8
require 'spec_helper'

describe Subspecies do

  it "has no statistics" do
    Subspecies.new.statistics.should be_nil
  end

  it "must have a species" do
    subspecies = FactoryGirl.build :subspecies, name: FactoryGirl.create(:name, name: 'Colobopsis'), species: nil
    subspecies.should_not be_valid
    subspecies.species = FactoryGirl.create :species, name: FactoryGirl.create(:name, name: 'christi')
    subspecies.save!
    subspecies.reload.species.name.to_s.should == 'christi'
  end

  it "should have a subfamily" do
    species = FactoryGirl.create :species
    subspecies = FactoryGirl.create :subspecies, :species => species
    subspecies.subfamily.should == species.subfamily
  end

  it "should have a genus" do
    species = FactoryGirl.create :species
    subspecies = FactoryGirl.create :subspecies, :species => species
    subspecies.genus.should == species.genus
  end

  describe "Full name" do
    it "is the the genus, the species, and the subspecies name" do
      taxon = FactoryGirl.create :subspecies, name: FactoryGirl.create(:name, name: 'Atta emeryi biggus'), :species => FactoryGirl.create(:species, name: FactoryGirl.create(:name, name: 'emeryi'), :genus => FactoryGirl.create(:genus, name: FactoryGirl.create(:name, name: 'Atta'), :subfamily => FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae'))))
      taxon.name.to_s.should == 'Atta emeryi biggus'
    end
  end

  describe "Full label" do
    it "is the the genus, the species, and the subspecies name" do
      taxon = FactoryGirl.create :subspecies, name: FactoryGirl.create(:name, name: 'biggus'), :species => FactoryGirl.create(:species, name: FactoryGirl.create(:name, name: 'emeryi'), :genus => FactoryGirl.create(:genus, name: FactoryGirl.create(:name, name: 'Atta'), :subfamily => FactoryGirl.create(:subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae'))))
      #taxon.label.should == '<i>Atta emeryi biggus</i>'
    end
  end

end
