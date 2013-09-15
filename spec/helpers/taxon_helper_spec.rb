# coding: UTF-8
require 'spec_helper'

describe TaxonHelper do
  describe "name_description" do
    it "should handle a subfamily" do
      subfamily = create_subfamily build_stubbed: true
      helper.name_description(subfamily).should == 'subfamily'
    end
    it "should handle a genus" do
      subfamily = create_subfamily build_stubbed: true
      genus = create_genus subfamily: subfamily
      helper.name_description(genus).should == "genus of #{subfamily.name}"
    end
    it "should handle a genus without a subfamily" do
      genus = create_genus subfamily: nil, build_stubbed: true
      helper.name_description(genus).should == "genus of (no subfamily)"
    end
    it "should handle a genus with a tribe" do
      subfamily = create_subfamily
      tribe = create_tribe subfamily: subfamily
      genus = create_genus tribe: tribe, build_stubbed: true
      helper.name_description(genus).should == "genus of #{tribe.name}"
    end
    it "should handle a new genus" do
      subfamily = create_subfamily build_stubbed: true
      genus = FactoryGirl.build :genus, subfamily: subfamily
      helper.name_description(genus).should == "new genus of #{subfamily.name}"
    end
    it "should handle a new species" do
      genus = create_genus 'Atta'
      species = FactoryGirl.build :species, genus: genus
      helper.name_description(species).should == "new species of <i>#{genus.name}</i>"
    end
    it "should handle a subspecies" do
      genus = create_genus 'Atta'
      species = FactoryGirl.build :species, genus: genus
      subspecies = FactoryGirl.build :subspecies, species: species, genus: genus
      helper.name_description(subspecies).should == "new subspecies of <i>#{species.name}</i>"
    end
    it "should handle a subspecies without a species" do
      genus = create_genus 'Atta'
      subspecies = FactoryGirl.build :subspecies, genus: genus, species: nil
      helper.name_description(subspecies).should == "new subspecies of (no species)"
    end
    it "should be html_safe" do
      subfamily = create_subfamily build_stubbed: true
      genus = create_genus subfamily: subfamily, build_stubbed: true
      helper.name_description(genus).should be_html_safe
    end
  end

  describe "Creating a link from AntCat to a taxon on AntCat" do
    it "should creat the link" do
      genus = create_genus 'Atta'
      helper.link_to_taxon(genus).should == %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
    end
  end
end
