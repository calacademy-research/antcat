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
      before do
        reference = FactoryGirl.create(:article_reference, citation_year: '1840', author_names: [FactoryGirl.create(:author_name, name: 'Shuckard')])
        authorship = FactoryGirl.create :citation, reference: reference
        name = FactoryGirl.create :species_name, name: 'Atta robusta'
        @protonym = FactoryGirl.create :protonym, authorship: authorship, name: name
        @species = create_species name: name, protonym: @protonym
        @homonym = create_species 'Atta major', status: 'homonym', protonym: @protonym
        @synonym = create_species 'Eciton major', status: 'synonym', protonym: @protonym
        @original_combination = create_species 'Furris major', status: 'original combination', protonym: @protonym
      end

      it "should export a valid species correctly" do
        @exporter.get_data(@species).should == ['Atta robusta', 'Shuckard', 1840, 'valid']
      end

      it "should export an invalid species correctly" do
        @exporter.get_data(@synonym).should == ['Eciton major', 'Shuckard', 1840, 'invalid']
      end

      describe "Outputting a number of taxa" do
        it "should sort its output by names in ranks" do
          file = double
          File.stub(:open).and_yield file

          @exporter.should_receive(:write).with(file, "name\tauthors\tyear\tvalid").ordered
          @exporter.should_receive(:write).with(file, "Atta robusta\t" + "Shuckard\t" + "1840\t" + "valid").ordered
          @exporter.should_receive(:write).with(file, "Atta major\t"   + "Shuckard\t" + "1840\t" + "invalid").ordered
          @exporter.should_receive(:write).with(file, "Eciton major\t" + "Shuckard\t" + "1840\t" + "invalid").ordered
          @exporter.should_not_receive(:write).with(file, "Furris major\t" + "Shuckard\t" + "1840\t" + "valid").ordered

          @exporter.export
        end
      end
    end

  end
end
