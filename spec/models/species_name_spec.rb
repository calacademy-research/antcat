# coding: UTF-8
require 'spec_helper'

describe SpeciesName do

  describe "Parsing words" do
    it "should parse words into a species name" do
      name = SpeciesName.parse_words ['Atta', 'major']
      name.name.should == 'Atta major'
      name.name_html.should == '<i>Atta major</i>'
      name.epithet.should == 'major'
      name.epithet_html.should == '<i>major</i>'
      name.protonym_html.should ==ajor</i>'
    end
  end

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major'
      name = SpeciesName.find name
      name.name.should == 'Atta major'
      name.to_html.should == '<i>Atta</i> <i>major</i>'
      name.epithet.should == 'major'
      name.epithet_html.should == '<i>major</i>'
    end
    it "escape bad characters" do
      name = Name.import genus_name: 'Atta', species_epithet: 'm>ajor'
      name = Name.find name
      name.epithet_html.should == '<i>m&gt;ajor</i>'
    end
    it "should reuse names" do
      Name.import genus_name: 'Atta', species_epithet: 'major'
      Name.count.should == 2
      Name.import genus_name: 'Atta', species_epithet: 'major'
      Name.count.should == 2
    end
    it "should not reuse name for another genus" do
      Name.import genus_name: 'Eciton', species_epithet: 'major'
      Name.count.should == 2
      Name.import genus_name: 'Atta', species_epithet: 'major'
      Name.count.should == 4
    end
    it "should import a species name with a subgenus name" do
      name = Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta', species_epithet: 'major'
      name = SpeciesName.find name
      name.epithet.should == 'major'
      name.name.should == 'Atta major'
      name.protonym_html.should == '<i>Atta</i> <i>(Subatta)</i> <i>major</i>'
    end
    it "should import from a genus name object and a species_group_epithet" do
      genus_name = create_genus('Eciton').name
      name = Name.import genus_name: genus_name, species_group_epithet: 'major'
      name = Name.find name
      name.name.should == 'Eciton major'
    end

  end

end
