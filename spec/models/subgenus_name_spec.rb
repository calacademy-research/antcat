# coding: UTF-8
require 'spec_helper'

describe SubgenusName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta'
      name = SubgenusName.find(name)
      name.name.should == 'Atta (Subatta)'
      name.epithet.should == 'Subatta'
    end
    it "should reuse names" do
      Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta'
      Name.count.should == 2
      Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta'
      Name.count.should == 2
    end
    it "should not reuse name for another genus" do
      Name.import genus_name: 'Eciton', subgenus_epithet: 'Subatta'
      Name.count.should == 2
      Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta'
      Name.count.should == 4
    end
  end

end
