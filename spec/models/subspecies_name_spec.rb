# coding: UTF-8
require 'spec_helper'

describe SubspeciesName do

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [{species_group_epithet: 'alpina'}]
      name = SubspeciesName.find name
      name.epithet.should == 'alpina'
      name.name.should == 'Atta major alpina'
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

    it "should handle a subspecies qualifiers" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [{:type => 'r.', species_group_epithet: 'alpina'}]
      name = SubspeciesName.find name
      name.epithet.should == 'alpina'
      name.name.should == 'Atta major r. alpina'
      #name.label.should == '<i>Atta major</i> r. <i>alpina</i>'
    end

    it "should handle multiple subspecies epithets" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [
        {species_group_epithet: 'alpina'},
        {species_group_epithet: 'superba', :type => 'r.'}
      ]
      name = SubspeciesName.find name
      name.epithet.should == 'alpina'
      name.name.should == 'Atta major alpina r. superba'
    end

    it "multiple subspecies epithets should create separate names for each epithet" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [
        {species_group_epithet: 'alpina'},
        {species_group_epithet: 'superba', :type => 'r.'}
      ]
      alpina = Name.find_by_epithet 'alpina'
      superba = Name.find_by_epithet 'superba'
      alpina.next_subspecies_name.should == superba
      superba.prior_subspecies_name.should == alpina
    end

    it "should import a subspecies name with a subgenus name" do
      name = Name.import genus_name: 'Atta', subgenus_epithet: 'Subatta', species_epithet: 'major', subspecies: [{:type => 'r.', species_group_epithet: 'alpina'}]
      SubspeciesName.find(name).to_s.should == 'Atta (Subatta) major r. alpina'
    end

    it "should report back on all its epithets if asked" do
      name = Name.import genus_name: 'Atta', species_epithet: 'major', subspecies: [
        {species_group_epithet: 'alpina'},
        {species_group_epithet: 'superba', :type => 'r.'}
      ]
      name.subspecies_epithets.should == 'major alpina r. superba'
    end
  end

end
