# frozen_string_literal: true

require 'rails_helper'

describe AntwebFormatter::Detax do
  include TestLinksHelpers

  describe "#call" do
    describe "tag: `TAX_TAG_REGEX` (taxa)" do
      let!(:taxon) { create :family }

      specify do
        expect(described_class["{tax #{taxon.id}}"]).to eq antweb_taxon_link(taxon)
      end
    end

    describe "tag: `TAXAC_TAG_REGEX` (taxa with author citation)" do
      let!(:taxon) { create :family }

      specify do
        expect(described_class["{taxac #{taxon.id}}"]).to eq "#{antweb_taxon_link(taxon)} #{taxon.author_citation}"
      end
    end

    describe "tag: `PRO_TAG_REGEX` (protonyms)" do
      let!(:protonym) { create :protonym }

      specify do
        expect(described_class["{pro #{protonym.id}}"]).to eq antweb_protonym_link(protonym)
      end
    end

    describe "tag: `REF_TAG_REGEX` (references)" do
      let!(:reference) { create :any_reference }

      specify do
        expect(described_class["{ref #{reference.id}}"]).to eq AntwebFormatter::ReferenceLink[reference]
      end
    end

    describe "tag: `MISSING_OR_UNMISSING_TAG` (missing and unmissing hardcoded taxon names)" do
      it 'renders the hardcoded name' do
        expect(described_class["Synonym of {missing <i>Atta</i>}"]).to eq "Synonym of <i>Atta</i>"
        expect(described_class["in family {unmissing Pices}"]).to eq "in family Pices"
      end
    end
  end
end
