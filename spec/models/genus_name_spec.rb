# coding: UTF-8
require 'spec_helper'

describe GenusName do

  describe "Decomposition" do
    it "should know its genus name" do
      name = GenusName.new name: 'Atta', epithet: 'Atta'
      expect(name.genus_name).to eq('Atta')
    end
  end

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta'
      name = GenusName.find name
      expect(name.name).to eq('Atta')
      expect(name.epithet).to eq('Atta')
      expect(name.to_s).to eq('Atta')
      expect(name.to_html).to eq('<i>Atta</i>')
      expect(name.epithet_html).to eq('<i>Atta</i>')
    end
    it "should escape bad characters" do
      name = Name.import genus_name: 'A>tta'
      expect(name.epithet_html).to eq('<i>A&gt;tta</i>')
    end
    it "should reuse names" do
      FactoryGirl.create :name, name: 'Atta'
      Name.import genus_name: 'Atta'
      expect(Name.count).to eq(1)
    end

  end

end
