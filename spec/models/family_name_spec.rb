# coding: UTF-8
require 'spec_helper'

describe FamilyName do

  describe "Importing" do
    it "should recognize its key and set its name appropriately" do
      name = Name.import family_name: 'Formicidae'
      FamilyName.find(name).name.should == 'Formicidae'
    end
  end

end
