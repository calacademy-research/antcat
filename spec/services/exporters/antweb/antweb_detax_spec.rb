require 'rails_helper'

describe Exporters::Antweb::AntwebDetax do
  include TestLinksHelpers

  describe "#call" do
    describe "tax tags (taxa)" do
      let!(:taxon) { create :family }

      specify do
        expect(described_class["{tax #{taxon.id}}"]).to eq antweb_taxon_link(taxon)
      end
    end

    describe "taxac tags (taxa with author citation)" do
      let!(:taxon) { create :family }

      specify do
        expect(described_class["{taxac #{taxon.id}}"]).to eq "#{antweb_taxon_link(taxon)} #{taxon.author_citation}"
      end
    end

    describe "ref tags (references)" do
      let!(:reference) { create :article_reference }

      specify do
        expect(described_class["{ref #{reference.id}}"]).to eq Exporters::Antweb::AntwebInlineCitation[reference]
      end
    end
  end
end
