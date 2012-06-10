# coding: UTF-8
require 'spec_helper'

describe SubgenusName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import subgenus_name: 'Atta'
      SubgenusName.find(name).name.should == 'Atta'
    end
    it "should reuse names" do
      FactoryGirl.create :name, name: 'Subatta'
      Name.import subgenus_name: 'Subatta'
      Name.count.should == 1
    end

  end

end



