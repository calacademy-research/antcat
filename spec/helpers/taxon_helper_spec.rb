require 'spec_helper'

describe TaxonHelper do
  describe "#taxon_link_or_deleted_string" do
    context "when taxon exists" do
      let(:taxon) { create :subfamily }

      it "returns a link" do
        expect(helper.taxon_link_or_deleted_string(taxon.id)).to include '<a href="/catalog'
      end
    end

    context "when taxon doesn't exist" do
      it "returns the id and more" do
        expect(helper.taxon_link_or_deleted_string(99999)).to eq "#99999 [deleted]"
      end

      it "allows custom deleted_label" do
        expect(helper.taxon_link_or_deleted_string(99999, "deleted")).to eq "deleted"
      end
    end
  end

  describe "#taxon_name_description" do
    it "handles subfamilies" do
      subfamily = build_stubbed :subfamily
      expect(helper.taxon_name_description(subfamily)).to eq 'subfamily'
    end

    it "handles genera" do
      subfamily = build_stubbed :subfamily
      genus = create_genus subfamily: subfamily, tribe: nil
      expect(helper.taxon_name_description(genus)).to eq "genus of #{subfamily.name.name}"
    end

    it "handles genera without a subfamily" do
      genus = create_genus subfamily: nil, tribe: nil
      expect(helper.taxon_name_description(genus)).to eq "genus of (no subfamily)"
    end

    it "handles genera with a tribe" do
      subfamily = create_subfamily
      tribe = create_tribe subfamily: subfamily
      genus = create_genus tribe: tribe
      expect(helper.taxon_name_description(genus)).to eq "genus of #{tribe.name.name}"
    end

    it "handles new genera" do
      subfamily = build_stubbed :subfamily
      genus = build :genus, subfamily: subfamily, tribe: nil
      expect(helper.taxon_name_description(genus)).to eq "new genus of #{subfamily.name.name}"
    end

    it "handles new species" do
      genus = create_genus 'Atta'
      species = build :species, genus: genus
      expect(helper.taxon_name_description(species)).to eq "new species of <i>#{genus.name.name}</i>"
    end

    it "handles subspecies" do
      genus = create_genus 'Atta'
      species = build :species, genus: genus
      subspecies = build :subspecies, species: species, genus: genus
      expect(helper.taxon_name_description(subspecies)).to eq "new subspecies of <i>#{species.name.name}</i>"
    end

    it "handles subspecies without a species" do
      genus = create_genus 'Atta'
      subspecies = build :subspecies, genus: genus, species: nil
      expect(helper.taxon_name_description(subspecies)).to eq "new subspecies of (no species)"
    end

    it "is html_safe" do
      subfamily = build_stubbed :subfamily
      genus = create_genus subfamily: subfamily
      expect(helper.taxon_name_description(genus)).to be_html_safe
    end
  end

  describe "#taxon_change_history", :versioning do
    it "shows nothing for old taxa" do
      taxon = create_genus
      expect(helper.taxon_change_history(taxon)).to be_nil
    end

    it "shows the adder for waiting taxa" do
      adder = create :editor
      taxon = create_taxon_version_and_change :waiting, adder

      change_history = helper.taxon_change_history taxon
      expect(change_history).to match /Added by/
      expect(change_history).to match /Brian Fisher/
      expect(change_history).to match /less than a minute ago/
    end

    it "shows the adder and the approver for approved taxa" do
      adder = create :editor
      approver = create :editor
      taxon = create_taxon_version_and_change :waiting, adder
      taxon.taxon_state.review_state = :waiting
      change = Change.find taxon.last_change.id
      change.update! approver: approver, approved_at: Time.current
      taxon.approve!

      change_history = helper.taxon_change_history taxon
      expect(change_history).to match /Added by/
      expect(change_history).to match /#{adder.name}/
      expect(change_history).to match /less than a minute ago/
      expect(change_history).to match /approved by/
      expect(change_history).to match /#{approver.name}/
      expect(change_history).to match /less than a minute ago/
    end
  end
end
