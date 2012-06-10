# coding: UTF-8
require 'spec_helper'

describe GenusName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta'
      GenusName.find(name).name.should == 'Atta'
    end
    it "should reuse names" do
      FactoryGirl.create :name, name: 'Atta'
      Name.import genus_name: 'Atta'
      Name.count.should == 1
    end

  end

end
