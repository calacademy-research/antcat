# coding: UTF-8
require 'spec_helper'

describe CleanNewlines do

  it "should remove newlines and linefeeds before saving" do
    taxon = FactoryGirl.create :genus, headline_notes_taxt: "Te\nxt"
    taxon.save!
    taxon.headline_notes_taxt.should == 'Text'
  end

  it "should handle all fields" do
    taxon = FactoryGirl.create :genus, headline_notes_taxt: "Te\nxt", type_taxt: "\nType"
    taxon.save!
    taxon.headline_notes_taxt.should == 'Text'
    taxon.type_taxt.should == 'Type'
  end

  it "should handle newlines and carriage returns" do
    taxon = FactoryGirl.create :genus, headline_notes_taxt: "\rTe\nxt"
    taxon.save!
    taxon.headline_notes_taxt.should == 'Text'
  end

  it "should handle nil" do
    taxon = FactoryGirl.create :genus, headline_notes_taxt: nil
    taxon.save!
    taxon.headline_notes_taxt.should be_nil
  end

  it "should handle an empty string" do
    taxon = FactoryGirl.create :genus, headline_notes_taxt: ''
    taxon.save!
    taxon.headline_notes_taxt.should be_empty
  end

end
