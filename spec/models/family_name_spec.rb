# coding: UTF-8
require 'spec_helper'

describe FamilyName do

  describe "Importing" do
    it "should recognize its key and set its name appropriately" do
      name = Name.import family_name: 'Formicidae'
      name = FamilyName.find(name)
      expect(name.name).to eq('Formicidae')
      expect(name.epithet).to eq('Formicidae')
      expect(name.to_s).to eq('Formicidae')
      expect(name.to_html).to eq('Formicidae')
      expect(name.epithet_html).to eq('Formicidae')
    end
    it "should reuse names" do
      Name.import family_name: 'Formicidae'
      Name.import family_name: 'Formicidae'
      expect(Name.count).to eq(1)
    end
  end

end
