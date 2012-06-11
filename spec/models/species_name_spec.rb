# coding: UTF-8
require 'spec_helper'

describe SpeciesName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major'
      name = SpeciesName.find name
      name.epithet.should == 'major'
      name.name.should == 'Atta major'
    end
    it "should reuse names" do
      Name.import genus_name: 'Atta', species_epithet: 'major'
      Name.count.should == 2
      Name.import genus_name: 'Atta', species_epithet: 'major'
      Name.count.should == 2
    end
    it "should not reuse name for another genus" do
      Name.import genus_name: 'Eciton', species_epithet: 'major'
      Name.count.should == 2
      Name.import genus_name: 'Atta', species_epithet: 'major'
      Name.count.should == 4
    end
    it "should import a species name with a subgenus name" do
      name = Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta', species_epithet: 'major'
      name = SpeciesName.find name
      name.epithet.should == 'major'
      name.name.should == 'Atta (Subatta) major'
    end

  end

end
