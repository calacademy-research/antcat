# frozen_string_literal: true

require 'rails_helper'

describe CatalogFormatter do
  include TestLinksHelpers

  describe ".link_to_taxon" do
    let(:taxon) { build_stubbed :family }

    specify { expect(described_class.link_to_taxon(taxon).html_safe?).to eq true }
    specify { expect(described_class.link_to_taxon(taxon)).to eq taxon_link(taxon) }
  end

  describe ".link_to_taxon_with_label" do
    let(:taxon) { build_stubbed :family }

    specify { expect(described_class.link_to_taxon_with_label(taxon, 'AntCat').html_safe?).to eq true }

    specify do
      expect(described_class.link_to_taxon_with_label(taxon, 'AntCat')).to eq taxon_link(taxon, 'AntCat')
    end
  end

  describe ".disco_mode_css" do
    it 'replaces spaces in statuses with underscores' do
      taxon = build_stubbed :family, :obsolete_combination
      expect(described_class.disco_mode_css(taxon)).to eq "obsolete_combination"
    end

    context 'when taxon is an `unresolved_homonym`' do
      let(:taxon) { build_stubbed :family, :unresolved_homonym }

      specify { expect(described_class.disco_mode_css(taxon)).to eq "valid unresolved-homonym" }
    end
  end
end