# coding: UTF-8
require 'spec_helper'

describe SubspeciesName do

  describe "Parsing words" do
    it "should parse words into a subspecies name" do
      name = SubspeciesName.parse_words ['Atta', 'major', 'minor']
      name.name.should == 'Atta major minor'
      name.name_html.should == '<i>Atta major minor</i>'
      name.epithet.should == 'minor'
      name.epithet_html.should == '<i>minor</i>'
      name.epithets.should == 'major minor'
      name.protonym_html.should == '<i>Atta major minor</i>'
    end
  end
  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [{species_group_epithet: 'alpina'}]
      name = SubspeciesName.find name
      name.name.should == 'Atta major alpina'
      name.to_html.should == '<i>Atta</i> <i>major</i> <i>alpina</i>'
      name.epithet.should == 'alpina'
      name.epithet_html.should == '<i>alpina</i>'
      name.epithets.should == 'major alpina'
    end

    it "should recognize a subspecies name with :subspecies_epithet as the key" do
      name = Name.import genus_name: 'Formica', species_epithet: 'rufa', subspecies: [
        {subspecies_epithet: 'obscuripes', type: 'r.'},
        {subspecies_epithet: 'whymperi', type: 'var.'},
      ]
      name = SubspeciesName.find name
      name.name.should == 'Formica rufa obscuripes whymperi'
    end

    it "escape bad characters" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [{species_group_epithet: 'alpi>na'}]
      name = SubspeciesName.find name
      name.name_html.should == '<i>Atta</i> <i>major</i> <i>alpi&gt;na</i>'
      name.epithet_html.should == '<i>alpi&gt;na</i>'
    end
    it "should reuse names" do
      attributes = {genus_name: 'Atta', species_epithet: 'major', subspecies: [{species_group_epithet: 'alpina'}]}
      Name.import attributes
      Name.count.should == 3
      Name.import attributes
      Name.count.should == 3
    end
    it "should not reuse name for another species" do
      Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [{species_group_epithet: 'alpina'}]
      Name.count.should == 3
      Name.import genus_name: 'Atta', species_epithet: 'minor', subspecies: [{species_group_epithet: 'alpina'}]
      Name.count.should == 5
    end

    it "should handle subspecies types" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [{:type => 'r.', species_group_epithet: 'alpina'}]
      name = SubspeciesName.find name
      name.to_s.should == 'Atta major alpina'
      name.to_html.should == '<i>Atta</i> <i>major</i> <i>alpina</i>'
      name.epithet.should == 'alpina'
      name.epithet_html.should == '<i>alpina</i>'
      name.epithets.should == 'major alpina'
      name.protonym_html.should == '<i>Atta</i> <i>major</i> r. <i>alpina</i>'
    end

    it "should import a subspecies name with a subgenus name" do
      name = Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta', species_epithet: 'major', subspecies: [{:type => 'r.', species_group_epithet: 'alpina'}]
      name = SubspeciesName.find name
      name.to_s.should == 'Atta major alpina'
      name.to_html.should == '<i>Atta</i> <i>major</i> <i>alpina</i>'
      name.epithet.should == 'alpina'
      name.epithet_html.should == '<i>alpina</i>'
      name.epithets.should == 'major alpina'
      name.protonym_html.should == '<i>Atta</i> <i>(Subatta)</i> <i>major</i> r. <i>alpina</i>'
    end

    it "should import a subspecies name designated by :subspecies_epithet" do
      name = Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta', species_epithet: 'major', subspecies: [{:type => 'r.', subspecies_epithet: 'alpina'}]
      name.to_s.should == 'Atta major alpina'
    end

    it "should import a subspecies, using the epithet from the headline, not the protonym" do
      name = Name.import genus: create_genus('Atta'), species_epithet: 'major', subspecies_epithet: 'alpinus', subspecies: [{:type => 'r.', subspecies_epithet: 'alpina'}]
      name.to_s.should == 'Atta major alpinus'
    end

  end
end
