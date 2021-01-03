# frozen_string_literal: true

require 'rails_helper'

describe AntwebFormatter::Detax do
  include AntwebTestLinksHelpers

  describe "#call" do
    describe "tag: `TAX_TAG_REGEX`" do
      let!(:taxon) { create :any_taxon }

      specify do
        expect(described_class["{tax #{taxon.id}}"]).to eq antweb_taxon_link(taxon)
      end
    end

    describe "tag: `TAXAC_TAG_REGEX`" do
      let!(:taxon) { create :any_taxon }

      specify do
        expect(described_class["{taxac #{taxon.id}}"]).to eq "#{antweb_taxon_link(taxon)} #{taxon.author_citation}"
      end
    end

    describe "tag: `PRO_TAG_REGEX`" do
      let!(:protonym) { create :protonym }

      specify do
        expect(described_class["{pro #{protonym.id}}"]).to eq antweb_protonym_link(protonym)
      end
    end

    describe "tag: `PROAC_TAG_REGEX`" do
      let!(:protonym) { create :protonym }

      specify do
        expect(described_class["{proac #{protonym.id}}"]).to eq "#{antweb_protonym_link(protonym)} #{protonym.author_citation}"
      end
    end

    describe "tag: `PROTT_TAG_REGEX`" do
      context "when protonym has a `terminal_taxon`" do
        let!(:protonym) { create :protonym, :genus_group_name }
        let!(:terminal_taxon) { create :genus, protonym: protonym }

        it "links the terminal taxon" do
          expect(described_class["{prott #{protonym.id}}"]).to eq antweb_taxon_link(terminal_taxon)
        end
      end

      context "when protonym does not have a `terminal_taxon`" do
        let!(:protonym) { create :protonym }

        it "links the protonym with a note" do
          expect(described_class["{prott #{protonym.id}}"]).to eq <<~HTML.squish
            #{antweb_protonym_link(protonym)}
            (protonym)
          HTML
        end
      end
    end

    describe "tag: `PROTTAC_TAG_REGEX`" do
      context "when protonym has a `terminal_taxon`" do
        let!(:protonym) { create :protonym, :genus_group_name }
        let!(:terminal_taxon) { create :genus, protonym: protonym }

        it "links the terminal taxon (with author citation)" do
          expect(described_class["{prottac #{protonym.id}}"]).
            to eq "#{antweb_taxon_link(terminal_taxon)} #{terminal_taxon.author_citation}"
        end
      end

      context "when protonym does not have a `terminal_taxon`" do
        let!(:protonym) { create :protonym }

        it "links the protonym with a note" do
          expect(described_class["{prottac #{protonym.id}}"]).to eq <<~HTML.squish
            #{antweb_protonym_link(protonym)}
            (protonym)
          HTML
        end
      end
    end

    describe "tag: `REF_TAG_REGEX`" do
      let!(:reference) { create :any_reference }

      specify do
        expect(described_class["{ref #{reference.id}}"]).to eq AntwebFormatter::ReferenceLink[reference]
      end
    end

    describe "tag: `MISSING_OR_UNMISSING_TAG_REGEX`" do
      it 'renders the hardcoded name' do
        expect(described_class["Synonym of {missing <i>Atta</i>}"]).to eq "Synonym of <i>Atta</i>"
        expect(described_class["Synonym of {missing2 <i>Atta</i>}"]).to eq "Synonym of <i>Atta</i>"
        expect(described_class["in family {unmissing Pices}"]).to eq "in family Pices"
      end
    end

    describe "tag: `MISSPELLING_TAG_REGEX`" do
      it 'renders the hardcoded name' do
        expect(described_class["Synonym of {misspelling <i>Atta</i>}"]).to eq "Synonym of <i>Atta</i>"
        expect(described_class["in family {misspelling Pices}"]).to eq "in family Pices"
      end
    end

    describe "tag: `HIDDENNOTE_TAG_REGEX`" do
      it 'removes the note tag and its content' do
        expect(described_class["Synonym of Lasius{hiddennote check reference} and Formica"]).
          to eq "Synonym of Lasius and Formica"
      end
    end
  end
end
