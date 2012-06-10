# coding: UTF-8
require 'spec_helper'

describe SubfamilyName do

  describe "Importing" do
    it "should recognize its key and set its name appropriately" do
      name = Name.import subfamily_name: 'Aneuretinae'
      SubfamilyName.find(name).name.should == 'Aneuretinae'
    end
    it "should reuse names" do
      FactoryGirl.create :name, name: 'Dolichoderinae'
      Name.import subfamily_name: 'Dolichoderinae'
      Name.count.should == 1
    end
  end

end
