require 'rails_helper'

describe ActivitiesHelper do
  include TestLinksHelpers

  describe "#taxon_link_or_deleted_string" do
    context "when taxon exists" do
      let(:taxon) { create :subfamily }

      it "returns a link" do
        expect(helper.taxon_link_or_deleted_string(taxon.id)).to include taxon_link(taxon)
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
end
