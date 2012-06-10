# coding: UTF-8
require 'spec_helper'

describe SubtribeName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import subtribe_name: 'Aneuretina'
      SubtribeName.find(name).name.should == 'Aneuretina'
    end
    it "should reuse names" do
      FactoryGirl.create :name, name: 'Dolichoderina'
      Name.import subtribe_name: 'Dolichoderina'
      Name.count.should == 1
    end

  end

end


