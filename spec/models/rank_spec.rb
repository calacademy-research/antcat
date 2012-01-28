# coding: UTF-8
require 'spec_helper'

describe Rank do
  it "should convert a symbol to a klass" do
    Rank(:genus).to_class.should == Genus
  end
  it "should convert a klass to a symbol" do
    Rank(:genus).to_sym.should == :genus
  end
  it "should do all these ranks" do
    [[:genus, Genus], [:tribe, Tribe]].each do |symbol, klass|
      Rank(symbol).to_class.should == klass
    end
  end
  it "should return a string" do
    Rank(:tribes).to_s.should == 'tribe'
  end
  it "should do caps" do
    Rank(:tribes).to_s(:capitalized).should == 'Tribe'
  end
  it "should do caps plural" do
    Rank(:tribes).to_s(:capitalized, :plural).should == 'Tribes'
  end
  it "should do plural symbol" do
    Rank('Genera').to_sym(:plural).should == :genera
  end
  it "should convert from a taxon to a symbol" do
    Rank(Genus.new).to_sym.should == :genus
  end
  it "should automatically singularize or pluralize depending on a count" do
    Rank(Genus.new).to_s(1).should == 'genus'
    Rank(Genus.new).to_s(2).should == 'genera'
  end
  it "should convert from an array of taxa" do
    Rank([Genus.new]).to_s.should == 'genus'
  end
end
