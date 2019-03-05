require 'spec_helper'

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

  describe ".antcat_taxon_link" do
    let(:taxon) { build_stubbed :family }

    it "includes 'antcat.org' in the url" do
      expect(described_class.antcat_taxon_link_with_name(taxon)).to eq <<-HTML.squish
        <a href="http://www.antcat.org/catalog/#{taxon.id}">Formicidae</a>
      HTML
    end

    specify { expect(described_class.antcat_taxon_link_with_name(taxon)).to be_html_safe }
  end

  describe "#call" do
    let(:filename) { "antweb_export_test" }

    it "writes data to the specified file" do
      file = instance_double('File')
      expect(File).to receive(:open).with(filename, "w").and_yield(file)
      expect(file).to receive(:puts).with(anything)
      described_class[filename]
    end
  end
end
