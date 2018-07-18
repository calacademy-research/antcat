require "spec_helper"

describe Markdowns::ParseAntcatHooks do
  describe "#try_linking_taxon_id" do
    let(:dummy) { described_class.new nil }

    context "existing taxon" do
      let!(:taxon) { create :species }

      it "links existing taxa" do
        expect(dummy.send(:try_linking_taxon_id, taxon.id.to_s)).
          to eq %Q(<a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>)
      end
    end

    context "missing taxon" do
      it "renders an error message" do
        expect(dummy.send(:try_linking_taxon_id, "9999")).
          to eq '<span class="broken-markdown-link"> could not find taxon with id 9999 </span>'
      end
    end
  end
end
