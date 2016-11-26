require "spec_helper"

describe AntcatMarkdown do
  let(:dummy) { AntcatMarkdownUtils.new nil }

  describe "#try_linking_taxon_id" do
    context "existing taxon" do
      it "links existing taxa" do
        taxon = create :species
        returned = dummy.send :try_linking_taxon_id, taxon.id.to_s

        expected = %Q[<a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>]
        expect(returned).to eq expected
      end
    end

    context "missing taxon" do
      it "renders an error message" do
        returned = dummy.send :try_linking_taxon_id, "9999"
        expect(returned).to eq '<span class="broken-markdown-link"> could not find taxon with id 9999 </span>'
      end
    end
  end
end
