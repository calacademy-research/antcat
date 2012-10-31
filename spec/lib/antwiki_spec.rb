# coding: UTF-8
require 'spec_helper'

describe Antwiki do

  describe "comparing its valid taxa to ours" do
    it "should report a missing taxon" do
      genus = create_genus
      antwiki_genus = FactoryGirl.create :antwiki_valid_taxon, name: genus.name.to_s
      another_antwiki_genus = FactoryGirl.create :antwiki_valid_taxon, name: 'Eciton'
      results = Antwiki.compare_valid
      results[:missing_from_antcat].should == ['Eciton']
      results[:invalid_in_antcat].should be_empty
    end
    it "should report a taxon that's found, but is invalid" do
      genus = create_genus 'Atta', status: 'synonym'
      antwiki_genus = FactoryGirl.create :antwiki_valid_taxon, name: genus.name.to_s
      results = Antwiki.compare_valid
      results[:invalid_in_antcat].should == ['Atta']
    end
  end

end
