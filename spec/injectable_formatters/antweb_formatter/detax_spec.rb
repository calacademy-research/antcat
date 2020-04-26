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

    describe "tag: `REF_TAG_REGEX` (references)" do
      let!(:reference) { create :any_reference }

      specify do
        expect(described_class["{ref #{reference.id}}"]).to eq AntwebFormatter::ReferenceLink[reference]
      end
    end
  end
end
