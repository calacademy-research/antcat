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

  describe "#taxon_change_history" do
    it "shows nothing for old taxa" do
      taxon = create :genus
      expect(helper.taxon_change_history(taxon)).to be_nil
    end

    it "shows the adder for waiting taxa" do
      adder = create :user, :editor
      taxon = create_taxon_version_and_change adder

      change_history = helper.taxon_change_history taxon
      expect(change_history).to match /Added by/
      expect(change_history).to match /Brian Fisher/
      expect(change_history).to match /less than a minute ago/
    end

    it "shows the adder and the approver for approved taxa" do
      adder = create :user, :editor
      approver = create :user, :editor
      taxon = create_taxon_version_and_change adder
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
