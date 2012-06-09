# coding: UTF-8
require 'spec_helper'

describe FamilyOrSubfamilyName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import '', family_or_subfamily_name: 'Formicidae'
      FamilyOrSubfamilyName.find(name).name.should == 'Formicidae'
    end

  end

end
