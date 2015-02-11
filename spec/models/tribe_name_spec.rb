# coding: UTF-8
require 'spec_helper'

describe TribeName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import tribe_name: 'Aneuretini'
      name = TribeName.find name.id
      expect(name.name).to eq('Aneuretini')
      expect(name.epithet).to eq('Aneuretini')
      expect(name.to_s).to eq('Aneuretini')
      expect(name.to_html).to eq('Aneuretini')
      expect(name.epithet_html).to eq('Aneuretini')
    end
    it "should reuse names" do
      FactoryGirl.create :name, name: 'Dolichoderini'
      Name.import tribe_name: 'Dolichoderini'
      expect(Name.count).to eq(1)
    end

  end

end

