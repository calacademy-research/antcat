require "spec_helper"

describe Markdowns::ParseAntcatHooks do
  describe "#try_linking_taxon_id" do
    context "existing taxon" do
      let!(:taxon) { create :species }

      it "links existing taxa" do
        expect(described_class["{tax #{taxon.id}}"]).
          to eq %(<a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>)
      end
    end

    context "missing taxon" do
      it "renders an error message" do
        expect(described_class["{tax 9999}"]).to eq <<~HTML.squish
          <span class="bold-warning">
            CANNOT FIND TAXON WITH ID 9999
            <a class="btn-normal btn-tiny" href="/panel/versions?item_id=9999">Search history?</a>
          </span>
        HTML
      end
    end
  end
end
