require 'spec_helper'

describe TaxonHelper do
  describe "name_description" do
    it "should handle a subfamily" do
      subfamily = create_subfamily build_stubbed: true
      expect(helper.name_description(subfamily)).to eq('subfamily')
    end
    it "should handle a genus" do
      subfamily = create_subfamily build_stubbed: true
      genus = create_genus subfamily: subfamily, tribe: nil
      expect(helper.name_description(genus)).to eq("genus of #{subfamily.name}")
    end
    it "should handle a genus without a subfamily" do
      genus = create_genus subfamily: nil, tribe: nil, build_stubbed: true
      expect(helper.name_description(genus)).to eq("genus of (no subfamily)")
    end
    it "should handle a genus with a tribe" do
      subfamily = create_subfamily
      tribe = create_tribe subfamily: subfamily
      genus = create_genus tribe: tribe, build_stubbed: true
      expect(helper.name_description(genus)).to eq("genus of #{tribe.name}")
    end
    it "should handle a new genus" do
      subfamily = create_subfamily build_stubbed: true
      genus = FactoryGirl.build :genus, subfamily: subfamily, tribe: nil
      expect(helper.name_description(genus)).to eq("new genus of #{subfamily.name}")
    end
    it "should handle a new species" do
      genus = create_genus 'Atta'
      species = FactoryGirl.build :species, genus: genus
      expect(helper.name_description(species)).to eq("new species of <i>#{genus.name}</i>")
    end
    it "should handle a subspecies" do
      genus = create_genus 'Atta'
      species = FactoryGirl.build :species, genus: genus
      subspecies = FactoryGirl.build :subspecies, species: species, genus: genus
      expect(helper.name_description(subspecies)).to eq("new subspecies of <i>#{species.name}</i>")
    end
    it "should handle a subspecies without a species" do
      genus = create_genus 'Atta'
      subspecies = FactoryGirl.build :subspecies, genus: genus, species: nil
      expect(helper.name_description(subspecies)).to eq("new subspecies of (no species)")
    end
    it "should be html_safe" do
      subfamily = create_subfamily build_stubbed: true
      genus = create_genus subfamily: subfamily, build_stubbed: true
      expect(helper.name_description(genus)).to be_html_safe
    end
  end

end
