# coding: UTF-8
require 'spec_helper'

describe SpeciesName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major'
      name = SpeciesName.find name
      name.name.should == 'major'
      name.full_name.should == 'Atta major'
    end

  end

end
