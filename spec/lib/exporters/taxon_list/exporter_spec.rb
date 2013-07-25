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

    it "should include the correct header" do
      @file.should_receive(:puts).with "name\tauthors\tyear\tvalid"
      @exporter.export
    end

    describe "Outputting taxa" do
      it "should export a species correctly" do
        reference = FactoryGirl.create(:article_reference, date: '1840', author_names: [FactoryGirl.create(:author_name, name: 'Shuckard')])
        authorship = FactoryGirl.create :citation, reference: reference
        name = FactoryGirl.create :species_name, name: 'Atta robusta'
        protonym = FactoryGirl.create :protonym, authorship: authorship, name: name
        @species = create_species name: name, protonym: protonym

        @exporter.get_data(@species).should == ['Atta robusta', 1840, 'Shuckard', 'valid']
      end
    end
  end

end
