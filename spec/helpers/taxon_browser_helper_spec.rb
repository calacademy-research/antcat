require 'spec_helper'

describe TaxonBrowserHelper do
  describe "#taxon_browser_link" do
    let(:taxon) { create :genus }

    it "formats" do
      expect(helper.taxon_browser_link(taxon))
        .to eq %[<a class="valid genus" href="/catalog/#{taxon.id}"><i>#{taxon.name}</i></a>]
    end
  end

  # Not tested: "nomen_nudum"/"collective_group_name"
  describe "#css_classes_for_status" do
    let(:taxon) { create :genus, name: create(:name, name: 'Atta') }

    it "returns the correct classes" do
      expect(helper.send(:css_classes_for_status, taxon)).to match_array ["valid"]
    end
  end
end
