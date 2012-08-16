# coding: UTF-8
require 'spec_helper'

describe TribeName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import tribe_name: 'Aneuretini'
      name = TribeName.find name
      name.name.should == 'Aneuretini'
      name.epithet.should == 'Aneuretini'
      name.to_s.should == 'Aneuretini'
      name.to_html.should == 'Aneuretini'
      name.epithet_html.should == 'Aneuretini'
    end
    it "should reuse names" do
      FactoryGirl.create :name, name: 'Dolichoderini'
      Name.import tribe_name: 'Dolichoderini'
      Name.count.should == 1
    end

  end

end

