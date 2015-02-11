# coding: UTF-8
require 'spec_helper'

describe SubgenusName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta'
      name = SubgenusName.find(name.id)
      expect(name.name).to eq('Atta (Subatta)')
      expect(name.epithet).to eq('Subatta')
      expect(name.to_s).to eq('Atta (Subatta)')
      expect(name.to_html).to eq('<i>Atta</i> <i>(Subatta)</i>')
      expect(name.epithet_html).to eq('<i>Subatta</i>')
    end
    it "should escape bad characters" do
      name = Name.import genus_name: 'Atta', subgenus_epithet: 'Suba>tta'
      expect(name.epithet_html).to eq('<i>Suba&gt;tta</i>')
    end
    it "should reuse names" do
      Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta'
      expect(Name.count).to eq(2)
      Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta'
      expect(Name.count).to eq(2)
    end
    it "should not reuse name for another genus" do
      Name.import genus_name: 'Eciton', subgenus_epithet: 'Subatta'
      expect(Name.count).to eq(2)
      Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta'
      expect(Name.count).to eq(4)
    end

    it "should import from a genus name object and a subgenus_epithet" do
      genus_name = create_genus('Eciton').name
      name = Name.import genus_name: genus_name, subgenus_epithet: 'Subatta'
      name = Name.find name.id
      expect(name.name).to eq('Eciton (Subatta)')
    end
  end

end
