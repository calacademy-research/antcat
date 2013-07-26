# coding: UTF-8
require 'spec_helper'

describe Exporters::TaxonList::Exporter do
  before do
    @exporter = Exporters::TaxonList::Exporter.new
  end

  it "should write its output to the right file" do
    File.should_receive(:open).with 'data/output/antcat_taxon_list.txt', 'w'
    @exporter.export
  end

  describe "Exporting" do
    before do
      @file = double
      File.stub(:open).and_yield @file
    end

    def create_taxon author_name, year
      reference = FactoryGirl.create(:article_reference, citation_year: year, author_names: [author_name])
      authorship = FactoryGirl.create :citation, reference: reference
      name = FactoryGirl.create :species_name
      protonym = FactoryGirl.create :protonym, authorship: authorship, name: name
      species = create_species name: name, protonym: protonym
    end

    describe "Outputting taxa" do
      it "should work" do
        fisher = FactoryGirl.create :author_name, name: 'Fisher, B.L.'
        bolton = FactoryGirl.create :author_name, name: 'Bolton, B.'
        3.times {|i| create_taxon fisher, '2013'}
        2.times {|i| create_taxon fisher, '2011'}
        1.times {|i| create_taxon bolton, '2000'}
        @exporter.should_receive(:write).with(@file, "Bolton, B.\t" + "2000\t" + '1').ordered
        @exporter.should_receive(:write).with(@file, "Fisher, B.L.\t" + "2011\t" + '2').ordered
        @exporter.should_receive(:write).with(@file, "Fisher, B.L.\t" + "2013\t" + '3').ordered
        @exporter.export
      end

    end
  end
end
