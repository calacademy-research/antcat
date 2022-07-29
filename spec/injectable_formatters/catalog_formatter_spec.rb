# frozen_string_literal: true

require 'rails_helper'

describe CatalogFormatter do
  include TestLinksHelpers

  describe ".link_to_taxon" do
    let(:taxon) { build_stubbed :any_taxon }

    specify { expect(described_class.link_to_taxon(taxon).html_safe?).to eq true }
    specify { expect(described_class.link_to_taxon(taxon)).to eq taxon_link(taxon) }
  end

  describe ".link_to_taxon_with_linked_author_citation" do
    let(:taxon) { create :any_taxon }

    specify { expect(described_class.link_to_taxon_with_linked_author_citation(taxon).html_safe?).to eq true }

    specify do
      expect(described_class.link_to_taxon_with_linked_author_citation(taxon)).to eq <<~HTML.squish
        #{taxon_link(taxon)} <span class="discreet-author-citation">#{reference_link(taxon.authorship_reference)}</span>
      HTML
    end
  end

  describe ".link_to_taxon_with_label" do
    let(:taxon) { build_stubbed :any_taxon }

    specify { expect(described_class.link_to_taxon_with_label(taxon, 'AntCat').html_safe?).to eq true }

    specify do
      expect(described_class.link_to_taxon_with_label(taxon, 'AntCat')).to eq taxon_link(taxon, 'AntCat')
    end
  end

  describe ".link_to_protonym_with_terminal_taxa" do
    let(:protonym) { create :protonym }

    context 'when protonym does not have any terminal taxa' do
      specify do
        expect(described_class.link_to_protonym_with_terminal_taxa(protonym)).to eq <<~HTML.squish
          #{protonym_link(protonym)} (no terminal taxon)
        HTML
      end
    end

    context 'when protonym has terminal taxa' do
      let!(:taxon_1) { create :family, protonym: protonym }
      let!(:taxon_2) { create :family, protonym: protonym }

      specify do
        expect(described_class.link_to_protonym_with_terminal_taxa(protonym)).to eq <<~HTML.squish
          #{protonym_link(protonym)} (#{taxon_link(taxon_1)}, #{taxon_link(taxon_2)})
        HTML
      end
    end
  end

  describe ".taxon_disco_mode_css" do
    it 'replaces spaces in statuses with dashes' do
      taxon = build_stubbed :any_taxon, :obsolete_combination
      expect(described_class.taxon_disco_mode_css(taxon)).to eq "obsolete-combination"
    end

    context 'when taxon is an `unresolved_homonym`' do
      let(:taxon) { build_stubbed :any_taxon, :unresolved_homonym }

      specify { expect(described_class.taxon_disco_mode_css(taxon)).to eq "valid unresolved-homonym" }
    end
  end

  describe ".link_to_reference" do
    let(:reference) { build_stubbed :any_reference }

    specify { expect(described_class.link_to_reference(reference).html_safe?).to eq true }
    specify { expect(described_class.link_to_reference(reference)).to eq reference_link(reference) }
  end
end
