# frozen_string_literal: true

require 'rails_helper'

describe AntwebFormatter do
  include TestLinksHelpers

  describe 'test support code in `TestLinksHelpers`' do
    let(:taxon) { build_stubbed :genus, :fossil }

    it 'returns the same as this code' do
      expect(described_class.link_to_taxon(taxon)).to eq antweb_taxon_link(taxon)
    end
  end

  describe ".link_to_taxon" do
    let(:taxon) { build_stubbed :family }

    specify { expect(described_class.link_to_taxon(taxon).html_safe?).to eq true }

    it "includes 'antcat.org' in the url" do
      expect(described_class.link_to_taxon(taxon)).to eq <<-HTML.squish
        <a href="https://www.antcat.org/catalog/#{taxon.id}">Formicidae</a>
      HTML
    end
  end

  describe ".link_to_taxon_with_label" do
    let(:taxon) { build_stubbed :family }

    specify { expect(described_class.link_to_taxon_with_label(taxon, 'AntCat').html_safe?).to eq true }

    it "includes 'antcat.org' in the url" do
      expect(described_class.link_to_taxon_with_label(taxon, 'AntCat')).to eq <<-HTML.squish
        <a href="https://www.antcat.org/catalog/#{taxon.id}">AntCat</a>
      HTML
    end
  end

  describe ".link_to_taxon_with_author_citation" do
    let(:taxon) { create :family }

    specify { expect(described_class.link_to_taxon_with_author_citation(taxon).html_safe?).to eq true }

    specify do
      expect(described_class.link_to_taxon_with_author_citation(taxon)).to eq <<-HTML.squish
        <a href="https://www.antcat.org/catalog/#{taxon.id}">Formicidae</a> #{taxon.author_citation}
      HTML
    end
  end
end
