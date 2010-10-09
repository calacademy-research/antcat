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
      Reference.stub!(:all).and_return mocks
      mocks.each {|mock| @importer.should_receive(:import_source_url_for).with(mock)}
      @importer.import
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
