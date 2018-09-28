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
        expect(described_class["{tax 9999}"]).
          to eq '<span class="broken-markdown-link"> could not find taxon with id 9999 </span>'
      end
    end
  end
end
