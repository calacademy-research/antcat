require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HolSourceUrlImporter do
  before do
    @bibliography = mock HolBibliography
    HolBibliography.stub!(:new).and_return @bibliography
    @importer = HolSourceUrlImporter.new
  end

  describe "importing source URL for all references" do
    it "should do nothing if there are no references" do
      @importer.import
    end

    it "should import each reference" do
      mocks = [mock_model(Reference), mock_model(Reference)]
      Reference.stub!(:sorted_by_author).and_return mocks
      mocks.each {|mock| @importer.should_receive(:import_source_url_for).with(mock)}
      @importer.import
    end

    it "should import references in order of their first author" do
      bolton = Factory :author, :name => 'Bolton'
      ward = Factory :author, :name => 'Ward'
      fisher = Factory :author, :name => 'Fisher'
      bolton_reference = Factory :reference, :authors => [bolton]
      first_ward_reference = Factory :reference, :authors => [ward]
      second_ward_reference = Factory :reference, :authors => [ward]
      fisher_reference = Factory :reference, :authors => [fisher]

      @importer.should_receive(:import_source_url_for).with(bolton_reference).ordered
      @importer.should_receive(:import_source_url_for).with(fisher_reference).ordered
      @importer.should_receive(:import_source_url_for).with(first_ward_reference).ordered
      @importer.should_receive(:import_source_url_for).with(second_ward_reference).ordered

      @importer.import
    end
  end

  describe "saving the authors it can't find" do
    it "should save the authors it can't find" do
      bolton = Factory :author, :name => 'bolton'
      first_bolton = Factory :reference, :authors => [bolton]
      second_bolton = Factory :reference, :authors => [bolton]
      ward = Factory :reference, :authors => [Factory(:author, :name => 'ward')]
      fisher = Factory :reference, :authors => [Factory(:author, :name => 'fisher')]
      @bibliography.stub!(:match).with(first_bolton).and_return({})
      @bibliography.stub!(:match).with(second_bolton).and_return({:source_url => 'source'})
      @bibliography.stub!(:match).with(ward).and_return({:source_url => 'source'})
      @bibliography.stub!(:match).with(fisher).and_return({:failure_reason => HolBibliography::NO_ENTRIES_FOR_AUTHOR})
      @importer.import
      @importer.missing_authors.should == ['fisher']
    end
  end

  describe "importing source URL for one reference" do
    it "ask the HOL bibliography for a match" do
      reference = Factory :reference 
      @bibliography.should_receive(:match).with(reference).and_return({:source_url => 'source_url'})
      @importer.import_source_url_for reference 
      reference.reload.source_url.should == 'source_url'
    end
  end
end
