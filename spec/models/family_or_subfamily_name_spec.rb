# coding: UTF-8
require 'spec_helper'

describe FamilyOrSubfamilyName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import family_or_subfamily_name: 'Formicidae'
      expect(FamilyOrSubfamilyName.find(name).name).to eq('Formicidae')
    end

  end

end
