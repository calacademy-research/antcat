# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::ParseCatalogTags do
  include TestLinksHelpers

  describe "#call" do
    context 'with unsafe tags' do
      it "does not remove them" do
        content = "<i>italics<i><i><script>xss</script></i>"
        expect(described_class[content]).to eq content
      end
    end

    describe "tag: `TAX_TAG`" do
      it "uses the HTML version of the taxon's name" do
        taxon = create :genus
        expect(described_class["{#{Taxt::TAX_TAG} #{taxon.id}}"]).to eq taxon_link(taxon)
      end

      context "when taxon does not exists" do
        it "adds a warning" do
          expect(described_class["{#{Taxt::TAX_TAG} 999}"]).to include "CANNOT FIND TAXON FOR TAG {#{Taxt::TAX_TAG} 999}"
        end
      end
    end

    describe "tag: `TAXAC_TAG`" do
      it "uses the HTML version of the taxon's name" do
        taxon = create :genus
        expect(described_class["{#{Taxt::TAXAC_TAG} #{taxon.id}}"]).to eq <<~HTML.squish
          #{taxon_link(taxon)}
          <span class="discret-author-citation">#{taxon_authorship_link(taxon)}</span>
        HTML
      end

      context "when taxon does not exists" do
        it "adds a warning" do
          expect(described_class["{#{Taxt::TAXAC_TAG} 999}"]).to include "CANNOT FIND TAXON FOR TAG {#{Taxt::TAXAC_TAG} 999}"
        end
      end
    end

    describe "tag: `PRO_TAG`" do
      it "uses the HTML version of the protonyms's name" do
        protonym = create :protonym
        expect(described_class["{#{Taxt::PRO_TAG} #{protonym.id}}"]).to eq protonym_link(protonym)
      end

      context "when protonym does not exists" do
        it "adds a warning" do
          expect(described_class["{#{Taxt::PRO_TAG} 999}"]).to include "CANNOT FIND PROTONYM FOR TAG {#{Taxt::PRO_TAG} 999}"
        end
      end
    end

    describe "tag: `PROAC_TAG`" do
      it "uses the HTML version of the protonyms's name" do
        protonym = create :protonym
        expect(described_class["{#{Taxt::PROAC_TAG} #{protonym.id}}"]).to eq <<~HTML.squish
          #{protonym_link(protonym)}
          <span class="discret-author-citation">#{reference_link(protonym.authorship_reference)}</span>
        HTML
      end

      context "when protonym does not exists" do
        it "adds a warning" do
          expect(described_class["{#{Taxt::PROAC_TAG} 999}"]).
            to include "CANNOT FIND PROTONYM FOR TAG {#{Taxt::PROAC_TAG} 999}"
        end
      end
    end

    describe "tag: `PROTT_TAG`" do
      context "when protonym has a `terminal_taxon`" do
        let!(:protonym) { create :protonym, :genus_group_name }
        let!(:terminal_taxon) { create :genus, protonym: protonym }

        it "links the terminal taxon" do
          expect(described_class["{#{Taxt::PROTT_TAG} #{protonym.id}}"]).to eq taxon_link(terminal_taxon)
        end
      end

      context "when protonym does not have a `terminal_taxon`" do
        let!(:protonym) { create :protonym }

        it "links the protonym with a note" do
          expect(described_class["{#{Taxt::PROTT_TAG} #{protonym.id}}"]).to eq <<~HTML.squish
            #{protonym_link(protonym)} (protonym)
            <span class="logged-in-only-bold-warning">protonym has no terminal taxon</span>
          HTML
        end
      end

      context "when protonym does not exists" do
        it "adds a warning" do
          expect(described_class["{#{Taxt::PROTT_TAG} 999}"]).
            to include "CANNOT FIND PROTONYM FOR TAG {#{Taxt::PROTT_TAG} 999}"
        end
      end
    end

    describe "tag: `PROTTAC_TAG`" do
      context "when protonym has a `terminal_taxon`" do
        let!(:protonym) { create :protonym, :genus_group_name }
        let!(:terminal_taxon) { create :genus, protonym: protonym }

        it "links the terminal taxon (with author citation)" do
          expect(described_class["{#{Taxt::PROTTAC_TAG} #{protonym.id}}"]).to eq <<~HTML.squish
            #{taxon_link(terminal_taxon)}
            <span class="discret-author-citation">#{taxon_authorship_link(terminal_taxon)}</span>
          HTML
        end
      end

      context "when protonym does not have a `terminal_taxon`" do
        let!(:protonym) { create :protonym }

        it "links the protonym with a note" do
          expect(described_class["{#{Taxt::PROTTAC_TAG} #{protonym.id}}"]).to eq <<~HTML.squish
            #{protonym_link(protonym)} (protonym)
            <span class="logged-in-only-bold-warning">protonym has no terminal taxon</span>
          HTML
        end
      end

      context "when protonym does not exists" do
        it "adds a warning" do
          expect(described_class["{#{Taxt::PROTTAC_TAG} 999}"]).
            to include "CANNOT FIND PROTONYM FOR TAG {#{Taxt::PROTTAC_TAG} 999}"
        end
      end
    end

    describe "tag: `REF_TAG`" do
      context 'when reference has a `key_with_suffixed_year_cache`' do
        let(:reference) { create :any_reference }

        it 'links the reference' do
          expect(reference.key_with_suffixed_year_cache).to_not eq nil

          expect(described_class["{#{Taxt::REF_TAG} #{reference.id}}"]).to eq reference_taxt_link(reference)
        end
      end

      context 'when reference has no `key_with_suffixed_year_cache`' do
        let(:reference) { create :any_reference }

        it 'generates it' do
          reference.update_columns key_with_suffixed_year_cache: nil
          expect(reference.key_with_suffixed_year_cache).to eq nil

          expect(described_class["{#{Taxt::REF_TAG} #{reference.id}}"]).to eq reference_taxt_link(reference)
        end
      end

      context "when reference does not exists" do
        it "adds a warning" do
          expect(described_class["{#{Taxt::REF_TAG} 999}"]).to include "CANNOT FIND REFERENCE FOR TAG {#{Taxt::REF_TAG} 999}"
        end
      end
    end

    describe "tag: `MISSING_TAG`" do
      it 'renders the hardcoded name' do
        expect(described_class["Synonym of {#{Taxt::MISSING_TAG} <i>Atta</i>}"]).
          to eq 'Synonym of <span class="logged-in-only-bold-warning"><i>Atta</i></span>'

        expect(described_class["in family {#{Taxt::MISSING_TAG} Ecitoninae}"]).
          to eq 'in family <span class="logged-in-only-bold-warning">Ecitoninae</span>'

        expect(described_class["in family {#{Taxt::MISSING_TAG}2 Ecitoninae}"]).
          to eq 'in family <span class="logged-in-only-bold-warning">Ecitoninae</span>'
      end
    end

    describe "tag: `UNMISSING_TAG`" do
      it 'renders the hardcoded name' do
        expect(described_class["Homonym of {#{Taxt::UNMISSING_TAG} <i>Decamera</i>}"]).
          to eq 'Homonym of <span class="logged-in-only-gray-bold-notice"><i>Decamera</i></span>'

        expect(described_class["in family {#{Taxt::UNMISSING_TAG} Pices}"]).
          to eq 'in family <span class="logged-in-only-gray-bold-notice">Pices</span>'
      end
    end

    describe "tag: `MISSPELLING_TAG`" do
      it 'renders the hardcoded name' do
        expect(described_class["Homonym of {#{Taxt::MISSPELLING_TAG} <i>Decamera</i>}"]).
          to eq 'Homonym of <span class="logged-in-only-gray-bold-notice"><i>Decamera</i></span>'

        expect(described_class["in family {#{Taxt::MISSPELLING_TAG} Pices}"]).
          to eq 'in family <span class="logged-in-only-gray-bold-notice">Pices</span>'
      end
    end

    describe "tag: `HIDDENNOTE_TAG`" do
      it 'wraps the note content in a span only visible to logged-in users' do
        expect(described_class["Synonym of Lasius{#{Taxt::HIDDENNOTE_TAG} check reference} and Formica"]).
          to eq 'Synonym of Lasius<span class="taxt-hidden-note"><b>Hidden editor note:</b> check reference</span> and Formica'
      end
    end
  end
end
