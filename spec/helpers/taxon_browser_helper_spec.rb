require 'spec_helper'

describe TaxonBrowserHelper do
  describe "#taxon_browser_link" do
    it "formats" do
      taxon = create :genus
      expect(helper.taxon_browser_link(taxon))
        .to eq %[<a class="genus name taxon valid" href="/catalog/#{taxon.id}"><i>#{taxon.name}</i></a>]
    end
  end

  # TODO add once the code is more stable
  # describe "#panel_header selected"
  # describe "#all_genera_link selected"
  # describe "#incertae_sedis_link selected"
  # describe "#toggle_valid_only_link"
end
