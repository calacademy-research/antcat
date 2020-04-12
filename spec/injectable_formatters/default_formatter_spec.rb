# frozen_string_literal: false

require 'rails_helper'

describe DefaultFormatter do
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
end
