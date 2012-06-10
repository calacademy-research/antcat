# coding: UTF-8
require 'spec_helper'

describe FamilyName do

  describe "Importing" do
    it "should recognize its key and set its name appropriately" do
      name = Name.import family_name: 'Formicidae'
      FamilyName.find(name).name.should == 'Formicidae'
    end
    it "should not reuse names" do
      Name.import family_name: 'Formicidae'
      Name.import family_name: 'Formicidae'
      Name.count.should == 2
    end
  end

end
