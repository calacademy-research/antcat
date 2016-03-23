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
end
