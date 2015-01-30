# coding: UTF-8
require 'spec_helper'

describe SubfamilyName do

  describe "Importing" do
    it "should recognize its key and set its name appropriately" do
      name = Name.import subfamily_name: 'Aneuretinae'
      name = SubfamilyName.find name
      expect(name.name).to eq('Aneuretinae')
      expect(name.epithet).to eq('Aneuretinae')
      expect(name.to_s).to eq('Aneuretinae')
      expect(name.to_html).to eq('Aneuretinae')
      expect(name.epithet_html).to eq('Aneuretinae')
    end
    it "should reuse names" do
      FactoryGirl.create :name, name: 'Dolichoderinae'
      Name.import subfamily_name: 'Dolichoderinae'
      expect(Name.count).to eq(1)
    end
  end

end
