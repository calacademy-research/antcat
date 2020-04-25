# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::ParseCatalogTags do
  include TestLinksHelpers

  describe "#call" do
    it "does not remove <i> tags" do
      content = "<i>italics<i><i><script>xss</script></i>"
      expect(described_class[content]).to eq "<i>italics<i><i>xss</i></i></i>"
    end

    describe "tag: `TAX_TAG_REGEX` (taxa)" do
      it "uses the HTML version of the taxon's name" do
        taxon = create :genus
        expect(described_class["{tax #{taxon.id}}"]).to eq taxon_link(taxon)
      end

      context "when taxon does not exists" do
        it "adds a warning" do
          expect(described_class["{tax 999}"]).to include "CANNOT FIND TAXON WITH ID 999"
        end
      end
    end

    describe "tag: `TAXAC_TAG_REGEX` (taxa with author citation)" do
      it "uses the HTML version of the taxon's name" do
        taxon = create :genus
        expect(described_class["{taxac #{taxon.id}}"]).to eq <<~HTML.squish
          #{taxon_link(taxon)}
          <span class="discret-author-citation"><a href="/references/#{taxon.authorship_reference.id}">#{taxon.author_citation}</a></span>
        HTML
      end

      context "when taxon does not exists" do
        it "adds a warning" do
          expect(described_class["{taxac 999}"]).to include "CANNOT FIND TAXON WITH ID 999"
        end
      end
    end

    describe "tag: `REF_TAG_REGEX` (references)" do
      context 'when reference has no expandable_reference_cache' do
        let(:reference) { create :any_reference, title: 'Pizza' }

        it 'generates it' do
          expect(reference.expandable_reference_cache).to eq nil
          expect(described_class["{ref #{reference.id}}"]).to include 'Pizza'
        end
      end

      context "when reference does not exists" do
        it "adds a warning" do
          expect(described_class["{ref 999}"]).to include "CANNOT FIND REFERENCE WITH ID 999"
        end
      end
    end
  end
end
