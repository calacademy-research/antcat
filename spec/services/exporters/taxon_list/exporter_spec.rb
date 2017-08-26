require 'spec_helper'

describe Exporters::TaxonList::Exporter do
  subject(:exporter) { described_class.new }

  it "writes its output to the right file" do
    expect(File).to receive(:open).with 'data/output/antcat_taxon_list.txt', 'w'
    exporter.export
  end

  describe "#export" do
    let(:file) { double }
    let(:fisher) { create :author_name, name: 'Fisher, B.L.' }
    let(:bolton) { create :author_name, name: 'Bolton, B.' }

    before do
      allow(File).to receive(:open).and_yield file

      3.times { |i| create_taxon fisher, '2013' }
      2.times { |i| create_taxon fisher, '2011' }
      1.times { |i| create_taxon bolton, '2000' }
    end

    specify do
      expect(exporter).to receive(:write).with(file, "Bolton, B.\t" + "2000\t" + '1').ordered
      expect(exporter).to receive(:write).with(file, "Fisher, B.L.\t" + "2011\t" + '2').ordered
      expect(exporter).to receive(:write).with(file, "Fisher, B.L.\t" + "2013\t" + '3').ordered
      exporter.export
    end
  end

  def create_taxon author_name, year
    reference = create :article_reference, citation_year: year, author_names: [author_name]
    authorship = create :citation, reference: reference
    name = create :species_name
    protonym = create :protonym, authorship: authorship, name: name
    species = create_species name: name, protonym: protonym
  end
end
