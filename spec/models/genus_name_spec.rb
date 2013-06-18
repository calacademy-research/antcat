# coding: UTF-8
require 'spec_helper'

describe GenusName do

  describe "epithet count" do
    it "should have none" do
      genus = create_genus 'Crematogaster (Lambaster)'
      genus.name.epithet_count.should be_zero
    end
  end

  describe "Importing" do

    it "should recognize its key and set its name appropriately" do
      name = Name.import genus_name: 'Atta'
      name = GenusName.find name
      name.name.should == 'Atta'
      name.epithet.should == 'Atta'
      name.to_s.should == 'Atta'
      name.to_html.should == '<i>Atta</i>'
      name.epithet_html.should == '<i>Atta</i>'
    end
    it "should escape bad characters" do
      name = Name.import genus_name: 'A>tta'
      name.epithet_html.should == '<i>A&gt;tta</i>'
    end
    it "should reuse names" do
      FactoryGirl.create :name, name: 'Atta'
      Name.import genus_name: 'Atta'
      Name.count.should == 1
    end

  end

end
