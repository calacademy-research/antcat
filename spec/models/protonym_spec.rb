# coding: UTF-8
require 'spec_helper'

describe Protonym do

  it "has an authorship" do
    authorship = Factory :citation
    protonym = Protonym.create! authorship: authorship
    protonym.reload.authorship.should == authorship
  end

  describe "Importing" do
  before do @reference = Factory :article_reference, bolton_key_cache: 'Latreille 1809' end

    it "should create the Protonym and the Citation, which is linked to an existing Reference" do
      data = {
        family_or_subfamily_name: "Formicariae",
        sic: true,
        fossil: true,
        authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}],
      }

      protonym = Protonym.import(data).reload

      protonym.rank.should == 'family_or_subfamily'
      protonym.name.should == 'Formicariae'
      protonym.authorship.pages.should == '124'
      protonym.authorship.reference.should == @reference
      protonym.fossil.should be_true
      protonym.sic.should be_true
    end

    it "should handle a tribe name protonym" do
      data = {tribe_name: "Aneuretini", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}

      protonym = Protonym.import(data).reload

      protonym.rank.should == 'tribe'
      protonym.name.should == 'Aneuretini'
      protonym.authorship.pages.should == '124'
      protonym.authorship.reference.should == @reference
    end

    it "should handle a subgenus protonym" do
      data = {subgenus_name: "Aneuretini", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}

      protonym = Protonym.import(data).reload

      protonym.rank.should == 'subgenus'
      protonym.name.should == 'Aneuretini'
      protonym.authorship.pages.should == '124'
      protonym.authorship.reference.should == @reference
    end

  end

end
