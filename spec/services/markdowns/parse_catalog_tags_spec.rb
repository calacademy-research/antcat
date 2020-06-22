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

    describe "tag: `PRO_TAG_REGEX` (protonyms)" do
      it "uses the HTML version of the protonyms's name" do
        protonym = create :protonym
        expect(described_class["{pro #{protonym.id}}"]).to eq protonym_link(protonym)
      end

      context "when protonym does not exists" do
        it "adds a warning" do
          expect(described_class["{pro 999}"]).to include "CANNOT FIND PROTONYM WITH ID 999"
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

    describe "tag: `MISSING_TAG_REGEX` (missing hardcoded taxon names)" do
      it 'renders the hardcoded name' do
        expect(described_class["Synonym of {missing <i>Atta</i>}"]).
          to eq 'Synonym of <span class="logged-in-only-bold-warning"><i>Atta</i></span>'

        expect(described_class["in family {missing Ecitoninae}"]).
          to eq 'in family <span class="logged-in-only-bold-warning">Ecitoninae</span>'
      end
    end

    describe "tag: `UNMISSING_TAG_REGEX` (unmissing hardcoded taxon names)" do
      it 'renders the hardcoded name' do
        expect(described_class["Homonym of {unmissing <i>Decamera</i>}"]).
          to eq 'Homonym of <span class="logged-in-only-gray-bold-notice"><i>Decamera</i></span>'

        expect(described_class["in family {unmissing Pices}"]).
          to eq 'in family <span class="logged-in-only-gray-bold-notice">Pices</span>'
      end
    end

    describe "tag: `MISSPELLING_TAG_REGEX` (misspelled hardcoded taxon names)" do
      it 'renders the hardcoded name' do
        expect(described_class["Homonym of {misspelling <i>Decamera</i>}"]).
          to eq 'Homonym of <span class="logged-in-only-gray-bold-notice"><i>Decamera</i></span>'

        expect(described_class["in family {misspelling Pices}"]).
          to eq 'in family <span class="logged-in-only-gray-bold-notice">Pices</span>'
      end
    end
  end
end
