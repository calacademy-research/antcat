require 'rails_helper'

describe Exporters::Antweb::Exporter do
  describe ".antcat_taxon_link" do
    let(:taxon) { build_stubbed :family }

    it "includes 'antcat.org' in the url" do
      expect(described_class.antcat_taxon_link(taxon)).to match "antcat.org"
    end

    it "uses 'AntCat' for the label" do
      expect(described_class.antcat_taxon_link(taxon)).to match "AntCat</a>"
    end
  end

  describe ".antcat_taxon_link_with_name" do
    let(:taxon) { build_stubbed :family }

    it "includes 'antcat.org' in the url" do
      expect(described_class.antcat_taxon_link_with_name(taxon)).to eq <<-HTML.squish
        <a href="https://www.antcat.org/catalog/#{taxon.id}">Formicidae</a>
      HTML
    end

    specify { expect(described_class.antcat_taxon_link_with_name(taxon)).to be_html_safe }
  end

  describe ".antcat_taxon_link_with_name_and_author_citation" do
    let(:taxon) { create :family }

    specify do
      expect(described_class.antcat_taxon_link_with_name_and_author_citation(taxon)).to eq <<-HTML.squish
        <a href="https://www.antcat.org/catalog/#{taxon.id}">Formicidae</a> #{taxon.author_citation}
      HTML
    end

    specify { expect(described_class.antcat_taxon_link_with_name_and_author_citation(taxon)).to be_html_safe }
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
