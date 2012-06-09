# coding: UTF-8
require 'spec_helper'

describe Protonym do

  it "has an authorship" do
    authorship = FactoryGirl.create :citation
    protonym = Protonym.create! name_factory('Protonym', authorship: authorship)
    Protonym.find(protonym).authorship.should == authorship
  end

  describe "Importing" do
    before do @reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Latreille 1809' end

    it "should create the Protonym and the Citation, which is linked to an existing Reference" do
      data = {
        family_or_subfamily_name: "Formicariae",
        sic: true,
        fossil: true,
        locality: 'U.S.A.',
        authorship: [{author_names: ["Latreille"], year: "1809", pages: "124", forms: 'w.q.'}],
      }

      protonym = Protonym.find Protonym.import(data)
      protonym.rank.should == 'family_or_subfamily'
      protonym.name.should == 'Formicariae'
      protonym.authorship.pages.should == '124'
      protonym.authorship.reference.should == @reference
      protonym.authorship.forms.should == 'w.q.'
      protonym.fossil.should be_true
      protonym.sic.should be_true
      protonym.locality.should == 'U.S.A.'
    end

    it "should handle a tribe protonym" do
      data = {tribe_name: "Aneuretini", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      protonym.rank.should == 'tribe'
      protonym.name.should == 'Aneuretini'
    end

    it "should handle a subtribe protonym" do
      data = {subtribe_name: 'Bothriomyrmecina', authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      protonym.rank.should == 'subtribe'
      protonym.name.should == 'Bothriomyrmecina'
    end

    it "should handle a genus protonym" do
      data = {genus_name: "Atta", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      protonym.rank.should == 'genus'
      protonym.name.should == 'Atta'
    end

    it "should handle a subgenus protonym" do
      data = {subgenus_name: "Aneuretini", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      protonym.rank.should == 'subgenus'
      protonym.name.should == 'Aneuretini'
    end

    it "should handle a species protonym" do
      data = {genus_name: "Heteromyrmex", species_epithet: 'atopogaster', authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      protonym.rank.should == 'species'
      protonym.name.should == 'Heteromyrmex atopogaster'
    end

    it "should handle a subspecies protonym"

  end

  describe "Cascading delete" do
    it "should delete the citation when the protonym is deleted" do
      genus = FactoryGirl.create :genus, tribe: nil, subfamily: nil
      Protonym.count.should == 1
      Citation.count.should == 1

      genus.destroy
      Protonym.count.should be_zero
      Citation.count.should be_zero
    end
  end

end
