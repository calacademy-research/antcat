# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::Exporter do
  describe ".antcat_taxon_link" do
    let(:taxon) { build_stubbed :family }

    it "includes 'antcat.org' in the url" do
      expect(described_class.antcat_taxon_link(taxon)).
        to eq %(<a href="https://www.antcat.org/catalog/#{taxon.id}">AntCat</a>)
    end
  end

  describe ".antcat_taxon_link_with_name" do
    let(:taxon) { build_stubbed :family }

    specify { expect(described_class.antcat_taxon_link_with_name(taxon).html_safe?).to eq true }

    it "includes 'antcat.org' in the url" do
      expect(described_class.antcat_taxon_link_with_name(taxon)).to eq <<-HTML.squish
        <a href="https://www.antcat.org/catalog/#{taxon.id}">Formicidae</a>
      HTML
    end
  end

  describe ".antcat_taxon_link_with_name_and_author_citation" do
    let(:taxon) { create :family }

    specify { expect(described_class.antcat_taxon_link_with_name_and_author_citation(taxon).html_safe?).to eq true }

    specify do
      expect(described_class.antcat_taxon_link_with_name_and_author_citation(taxon)).to eq <<-HTML.squish
        <a href="https://www.antcat.org/catalog/#{taxon.id}">Formicidae</a> #{taxon.author_citation}
      HTML
    end
  end

  describe "#call" do
    let(:filename) { "antweb_export_test" }
    let(:file) { instance_double('File') }

    it "writes data to the specified file" do
      expect(File).to receive(:open).with(filename, "w").and_yield(file)
      expect(file).to receive(:puts).with(anything)
      described_class[filename]
    end

    it "calls `Exporters::Antweb::ExportTaxon`" do
      allow(File).to receive(:open).with(filename, "w").and_yield(file)
      allow(file).to receive(:puts).with(anything)

      taxon = create :family
      expect(Exporters::Antweb::ExportTaxon).to receive(:new).with(taxon).and_call_original
      described_class[filename]
    end
  end
end
