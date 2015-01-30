# coding: UTF-8
require 'spec_helper'

describe SubspeciesName do

  describe "Name parts" do
    it "should know its species epithet" do
      name = SubspeciesName.new name: 'Atta major minor', epithet: 'minor', epithets: 'major minor'
      expect(name.genus_epithet).to eq('Atta')
      expect(name.species_epithet).to eq('major')
      expect(name.subspecies_epithets).to eq('minor')
    end
  end

  describe "Parsing words" do
    it "should parse words into a subspecies name" do
      name = SubspeciesName.parse_words ['Atta', 'major', 'minor']
      expect(name.name).to eq('Atta major minor')
      expect(name.name_html).to eq('<i>Atta major minor</i>')
      expect(name.epithet).to eq('minor')
      expect(name.epithet_html).to eq('<i>minor</i>')
      expect(name.epithets).to eq('major minor')
      expect(name.protonym_html).to eq('<i>Atta major minor</i>')
    end
  end

  describe "Changing the species of a subspecies name" do
    it "should replace the species part of the name and fix all the other parts, too" do
      subspecies_name = SubspeciesName.new(
        name: 'Atta major minor',
        name_html: '<i>Atta major minor</i>',
        epithet: 'minor',
        epithet_html: '<i>minor</i>',
        epithets: 'major minor')

      species_name = SpeciesName.new(
        name: 'Eciton niger',
        name_html: '<i>Eciton niger</i>',
        epithet: 'niger',
        epithet_html: '<i>niger</i>')

      subspecies_name.change_parent species_name

      expect(subspecies_name.name).to eq('Eciton niger minor')
      expect(subspecies_name.name_html).to eq('<i>Eciton niger minor</i>')
      expect(subspecies_name.epithet).to eq('minor')
      expect(subspecies_name.epithet_html).to eq('<i>minor</i>')
      expect(subspecies_name.epithets).to eq('niger minor')
    end
    it "should handle more than one subspecies epithet" do
      subspecies_name = SubspeciesName.new(
        name: 'Atta major minor medii',
        name_html: '<i>Atta major minor medii</i>',
        epithet: 'medii',
        epithet_html: '<i>medii</i>',
        epithets: 'major minor medii')

      species_name = SpeciesName.new(
        name: 'Eciton niger',
        name_html: '<i>Eciton niger</i>',
        epithet: 'niger',
        epithet_html: '<i>niger</i>')

      subspecies_name.change_parent species_name

      expect(subspecies_name.name).to eq('Eciton niger minor medii')

      expect(subspecies_name.name_html).to eq('<i>Eciton niger minor medii</i>')
      expect(subspecies_name.epithet).to eq('medii')
      expect(subspecies_name.epithet_html).to eq('<i>medii</i>')
      expect(subspecies_name.epithets).to eq('niger minor medii')
    end
    it "should raise an error if the new name already exists for a different taxon" do
      existing_subspecies_name = SubspeciesName.create! name: 'Eciton niger minor', epithet: 'minor', epithets: 'niger minor'
      subspecies = create_subspecies 'Eciton niger minor', name: existing_subspecies_name
      subspecies_name = SubspeciesName.create! name: 'Atta major minor', epithet: 'minor', epithets: 'major minor'
      species_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'
      protonym_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'

      expect {subspecies_name.change_parent species_name}.to raise_error
    end
    it "should not raise an error if the new name already exists, but is an orphan" do
      orphan_subspecies_name = SubspeciesName.create! name: 'Eciton niger minor', epithet: 'minor', epithets: 'niger minor'
      subspecies_name = SubspeciesName.create! name: 'Atta major minor', epithet: 'minor', epithets: 'major minor'
      species_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'
      protonym_name = SpeciesName.create! name: 'Eciton niger', epithet: 'niger'
      expect {subspecies_name.change_parent species_name}.not_to raise_error
    end
  end

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [{species_group_epithet: 'alpina'}]
      name = SubspeciesName.find name
      expect(name.name).to eq('Atta major alpina')
      expect(name.to_html).to eq('<i>Atta</i> <i>major</i> <i>alpina</i>')
      expect(name.epithet).to eq('alpina')
      expect(name.epithet_html).to eq('<i>alpina</i>')
      expect(name.epithets).to eq('major alpina')
    end

    it "should recognize a subspecies name with :subspecies_epithet as the key" do
      name = Name.import genus_name: 'Formica', species_epithet: 'rufa', subspecies: [
        {subspecies_epithet: 'obscuripes', type: 'r.'},
        {subspecies_epithet: 'whymperi', type: 'var.'},
      ]
      name = SubspeciesName.find name
      expect(name.name).to eq('Formica rufa obscuripes whymperi')
    end

    it "escape bad characters" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [{species_group_epithet: 'alpi>na'}]
      name = SubspeciesName.find name
      expect(name.name_html).to eq('<i>Atta</i> <i>major</i> <i>alpi&gt;na</i>')
      expect(name.epithet_html).to eq('<i>alpi&gt;na</i>')
    end
    it "should reuse names" do
      attributes = {genus_name: 'Atta', species_epithet: 'major', subspecies: [{species_group_epithet: 'alpina'}]}
      Name.import attributes
      expect(Name.count).to eq(3)
      Name.import attributes
      expect(Name.count).to eq(3)
    end
    it "should not reuse name for another species" do
      Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [{species_group_epithet: 'alpina'}]
      expect(Name.count).to eq(3)
      Name.import genus_name: 'Atta', species_epithet: 'minor', subspecies: [{species_group_epithet: 'alpina'}]
      expect(Name.count).to eq(5)
    end

    it "should handle subspecies types" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [{:type => 'r.', species_group_epithet: 'alpina'}]
      name = SubspeciesName.find name
      expect(name.to_s).to eq('Atta major alpina')
      expect(name.to_html).to eq('<i>Atta</i> <i>major</i> <i>alpina</i>')
      expect(name.epithet).to eq('alpina')
      expect(name.epithet_html).to eq('<i>alpina</i>')
      expect(name.epithets).to eq('major alpina')
      expect(name.protonym_html).to eq('<i>Atta</i> <i>major</i> r. <i>alpina</i>')
    end

    it "should import a subspecies name with a subgenus name" do
      name = Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta', species_epithet: 'major', subspecies: [{:type => 'r.', species_group_epithet: 'alpina'}]
      name = SubspeciesName.find name
      expect(name.to_s).to eq('Atta major alpina')
      expect(name.to_html).to eq('<i>Atta</i> <i>major</i> <i>alpina</i>')
      expect(name.epithet).to eq('alpina')
      expect(name.epithet_html).to eq('<i>alpina</i>')
      expect(name.epithets).to eq('major alpina')
      expect(name.protonym_html).to eq('<i>Atta</i> <i>(Subatta)</i> <i>major</i> r. <i>alpina</i>')
    end

    it "should import a subspecies name designated by :subspecies_epithet" do
      name = Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta', species_epithet: 'major', subspecies: [{:type => 'r.', subspecies_epithet: 'alpina'}]
      expect(name.to_s).to eq('Atta major alpina')
    end

    it "should import a subspecies, using the epithet from the headline, not the protonym" do
      name = Name.import genus: create_genus('Atta'), species_epithet: 'major', subspecies_epithet: 'alpinus', subspecies: [{:type => 'r.', subspecies_epithet: 'alpina'}]
      expect(name.to_s).to eq('Atta major alpinus')
    end

  end

  describe "Subspecies epithets" do
    it "should return the subspecies epithets minus the species epithet" do
      name = SubspeciesName.new name: 'Acus major minor medium', name_html: '<i>Acus major minor medium</i>', epithet: 'medium',
        epithet_html: '<i>medium</i>', epithets: 'major minor medium', protonym_html: '<i>Acus major minor medium</i>'
      expect(name.subspecies_epithets).to eq('minor medium')
    end
  end

end
