require 'rails_helper'

describe TaxonBrowserHelper do
  describe "#taxon_browser_link" do
    let(:taxon) { build_stubbed :genus }

    specify do
      expect(helper.taxon_browser_link(taxon)).
        to eq %(<a class="valid genus" href="/catalog/#{taxon.id}"><i>#{taxon.name.name}</i></a>)
    end
  end
end
