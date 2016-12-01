require 'spec_helper'

describe TaxonHelper do
  describe "#taxon_link_or_deleted_string" do
    context "taxon exists" do
      it "returns a link" do
        actual = helper.taxon_link_or_deleted_string create_genus.id
        expect(actual).to include '<a href="/catalog'
      end
    end

    context "taxon doesn't exist" do
      it "returns a string" do
        actual = helper.taxon_link_or_deleted_string 999123
        expect(actual).to eq "#999123 [deleted]"
      end
    end
  end

  describe "#taxon_name_description" do
    it "handles subfamilies" do
      subfamily = create_subfamily build_stubbed: true
      expect(helper.taxon_name_description subfamily).to eq 'subfamily'
    end

    it "handles genera" do
      subfamily = create_subfamily build_stubbed: true
      genus = create_genus subfamily: subfamily, tribe: nil
      expect(helper.taxon_name_description genus).to eq "genus of #{subfamily.name}"
    end

    it "handles genera without a subfamily" do
      genus = create_genus subfamily: nil, tribe: nil, build_stubbed: true
      expect(helper.taxon_name_description genus).to eq "genus of (no subfamily)"
    end

    it "handles genera with a tribe" do
      subfamily = create_subfamily
      tribe = create_tribe subfamily: subfamily
      genus = create_genus tribe: tribe, build_stubbed: true
      expect(helper.taxon_name_description genus).to eq "genus of #{tribe.name}"
    end

    it "handles new genera" do
      subfamily = create_subfamily build_stubbed: true
      genus = build :genus, subfamily: subfamily, tribe: nil
      expect(helper.taxon_name_description genus).to eq "new genus of #{subfamily.name}"
    end

    it "handles new species" do
      genus = create_genus 'Atta'
      species = build :species, genus: genus
      expect(helper.taxon_name_description species).to eq "new species of <i>#{genus.name}</i>"
    end

    it "handles subspecies" do
      genus = create_genus 'Atta'
      species = build :species, genus: genus
      subspecies = build :subspecies, species: species, genus: genus
      expect(helper.taxon_name_description subspecies).to eq "new subspecies of <i>#{species.name}</i>"
    end

    it "handles subspecies without a species" do
      genus = create_genus 'Atta'
      subspecies = build :subspecies, genus: genus, species: nil
      expect(helper.taxon_name_description subspecies).to eq "new subspecies of (no species)"
    end

    it "is html_safe" do
      subfamily = create_subfamily build_stubbed: true
      genus = create_genus subfamily: subfamily, build_stubbed: true
      expect(helper.taxon_name_description genus).to be_html_safe
    end
  end
end
