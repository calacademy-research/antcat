# coding: UTF-8
require 'spec_helper'

describe SubtribeName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import subtribe_name: 'Aneuretina'
      name = SubtribeName.find name.id
      expect(name.name).to eq('Aneuretina')
      expect(name.epithet).to eq('Aneuretina')
      expect(name.to_s).to eq('Aneuretina')
      expect(name.to_html).to eq('Aneuretina')
      expect(name.epithet_html).to eq('Aneuretina')
    end
    it "should reuse names" do
      FactoryGirl.create :name, name: 'Dolichoderina'
      Name.import subtribe_name: 'Dolichoderina'
      expect(Name.count).to eq(1)
    end

  end

end


