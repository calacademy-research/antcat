# frozen_string_literal: true

require 'rails_helper'

describe AntwebFormatter do
  describe ".link_to_taxon" do
    let(:taxon) { build_stubbed :any_taxon }

    specify { expect(described_class.link_to_taxon(taxon).html_safe?).to eq true }

    specify do
      expect(described_class.link_to_taxon(taxon)).to eq <<-HTML.squish
        <a href="https://www.antcat.org/catalog/#{taxon.id}">#{taxon.name.name}</a>
      HTML
    end
  end

  describe ".link_to_taxon_with_label" do
    let(:taxon) { build_stubbed :any_taxon }

    specify { expect(described_class.link_to_taxon_with_label(taxon, 'AntCat').html_safe?).to eq true }

    specify do
      expect(described_class.link_to_taxon_with_label(taxon, 'AntCat')).to eq <<-HTML.squish
        <a href="https://www.antcat.org/catalog/#{taxon.id}">AntCat</a>
      HTML
    end
  end

  describe ".link_to_taxon_with_author_citation" do
    let(:taxon) { create :any_taxon }

    specify { expect(described_class.link_to_taxon_with_author_citation(taxon).html_safe?).to eq true }

    specify do
      expect(described_class.link_to_taxon_with_author_citation(taxon)).to eq <<-HTML.squish
        <a href="https://www.antcat.org/catalog/#{taxon.id}">#{taxon.name.name}</a> #{taxon.author_citation}
      HTML
    end
  end

  describe ".link_to_protonym" do
    let(:protonym) { create :protonym, :genus_group, :fossil }

    # TODO: Check AntWeb. Skipped as an experiment.
    # specify { expect(described_class.link_to_protonym(protonym).html_safe?).to eq true }

    it "includes 'antcat.org' in the url" do
      expect(described_class.link_to_protonym(protonym)).to eq <<-HTML.squish
        <a href="https://www.antcat.org/protonyms/#{protonym.id}"><i>†</i><i>#{protonym.name.name}</i></a>
      HTML
    end
  end

  describe ".link_to_protonym_with_author_citation" do
    let(:protonym) { create :protonym, :genus_group, :fossil }

    specify { expect(described_class.link_to_protonym_with_author_citation(protonym).html_safe?).to eq true }

    specify do
      expect(described_class.link_to_protonym_with_author_citation(protonym)).to eq <<-HTML.squish
        <a href="https://www.antcat.org/protonyms/#{protonym.id}"><i>†</i><i>#{protonym.name.name}</i></a> #{protonym.author_citation}
      HTML
    end
  end
end
