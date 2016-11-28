require 'spec_helper'

describe TaxonBrowserHelper do
  describe "#taxon_browser_link" do
    it "formats" do
      taxon = create :genus
      expect(helper.taxon_browser_link(taxon))
        .to eq %[<a class="genus name taxon valid" href="/catalog/#{taxon.id}"><i>#{taxon.name}</i></a>]
    end
  end
end
