require 'spec_helper'

describe Exporters::Antweb::Exporter do
  subject(:exporter) { described_class.new('dummy_file.txt') }

  describe ".antcat_taxon_link" do
    let(:taxon) { build_stubbed :family }
    let(:link) { exporter.class.antcat_taxon_link taxon }

    it "includes 'antcat.org' in the url" do
      expect(link).to match "antcat.org"
    end

    it "uses 'AntCat' for the label" do
      expect(link).to match "AntCat</a>"
    end
  end

  describe ".antcat_taxon_link" do
    let(:taxon) { build_stubbed :family }
    let(:link) { exporter.class.antcat_taxon_link_with_name taxon }

    it "includes 'antcat.org' in the url" do
      expect(link).to eq <<-HTML.squish
        <a class="link_to_external_site"
        href="http://www.antcat.org/catalog/#{taxon.id}">Formicidae</a>
      HTML
    end

    it "is html_safe" do
      expect(link).to be_html_safe
    end
  end

  describe "#call" do
    # TODO
  end
end
