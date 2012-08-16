# coding: UTF-8
require 'spec_helper'

describe FamilyName do

  describe "Importing" do
    it "should recognize its key and set its name appropriately" do
      name = Name.import family_name: 'Formicidae'
      name = FamilyName.find(name)
      name.name.should == 'Formicidae'
      name.epithet.should == 'Formicidae'
      name.to_s.should == 'Formicidae'
      name.to_html.should == 'Formicidae'
      name.epithet_html.should == 'Formicidae'
    end
    it "should reuse names" do
      Name.import family_name: 'Formicidae'
      Name.import family_name: 'Formicidae'
      Name.count.should == 1
    end
  end

end
