require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hol::SourceUrlImporter do
  before do
    @bibliography = mock Hol::Bibliography
    Hol::Bibliography.stub!(:new).and_return @bibliography
    @importer = Hol::SourceUrlImporter.new
    @importer.stub!(:source_url_exists?).and_return(true)
  end

  describe "importing source URL for all references" do
    it "should do nothing if there are no references" do
      @importer.import
    end

    it "should import each reference" do
      mocks = [mock_model(Reference), mock_model(Reference)]
      Reference.stub!(:sorted_by_author_name).and_return mocks
      mocks.each {|mock| @importer.should_receive(:import_source_url_for).with(mock).and_return 'asdf'}
      @importer.import
    end

    it "should not try to import if it already has a source URL" do
      FakeWeb.register_uri(:any, "http://url.com", :body => "Hello World!")
      no_source_url = Factory :reference
      with_source_url = Factory :reference, :source_url => 'url.com'
      @bibliography.should_receive(:match).with(no_source_url).and_return({:source_url => 'url.com'})
      @bibliography.should_not_receive(:match).with(with_source_url)
      @importer.import
      @importer.processed_count.should == 2
      @importer.success_count.should == 2
      @importer.already_imported_count.should == 1
    end

    it "should import references in order of their first author" do
      bolton = Factory :author_name, :name => 'Bolton'
      ward = Factory :author_name, :name => 'Ward'
      fisher = Factory :author_name, :name => 'Fisher'
      bolton_reference = Factory :reference, :author_names => [bolton]
      first_ward_reference = Factory :reference, :author_names => [ward]
      second_ward_reference = Factory :reference, :author_names => [ward]
      fisher_reference = Factory :reference, :author_names => [fisher]

      @importer.should_receive(:import_source_url_for).with(bolton_reference).ordered.and_return 'asdf'
      @importer.should_receive(:import_source_url_for).with(fisher_reference).ordered.and_return 'asdf'
      @importer.should_receive(:import_source_url_for).with(first_ward_reference).ordered.and_return 'asdf'
      @importer.should_receive(:import_source_url_for).with(second_ward_reference).ordered.and_return 'asdf'

      @importer.import
    end
  end

  describe "saving the authors it can't find" do
    it "should save the authors it can't find" do
      bolton = Factory :author_name, :name => 'bolton'
      first_bolton = Factory :reference, :author_names => [bolton]
      second_bolton = Factory :reference, :author_names => [bolton]
      ward = Factory :reference, :author_names => [Factory(:author_name, :name => 'ward')]
      fisher = Factory :reference, :author_names => [Factory(:author_name, :name => 'fisher')]
      another_fisher = Factory :reference, :author_names => [Factory(:author_name, :name => 'fisher')]
      @bibliography.stub!(:match).with(first_bolton).and_return({})
      @bibliography.stub!(:match).with(second_bolton).and_return({:source_url => 'source'})
      @bibliography.stub!(:match).with(ward).and_return({:source_url => 'source'})
      @bibliography.stub!(:match).with(fisher).and_return({:status => Hol::Bibliography::NO_ENTRIES_FOR_AUTHOR})
      @bibliography.stub!(:match).with(another_fisher).and_return({:status => Hol::Bibliography::NO_ENTRIES_FOR_AUTHOR})
      @importer.import
      @importer.missing_authors.should == ['fisher']
      @importer.missing_author_failure_count.should == 2
    end
  end

  describe "recording counts of successful imports and each kind of failure" do
    it "should record the number of successful and unsuccessful imports" do
      success = Factory :reference
      failure = Factory :reference
      @bibliography.stub!(:match).with(failure).and_return({})
      @bibliography.stub!(:match).with(success).and_return({:source_url => 'source'})
      @importer.import
      @importer.processed_count.should == 2
      @importer.success_count.should == 1
    end

    it "should record the number of failures because reference was to a book" do
      success = Factory :reference
      failure = Factory :book_reference
      @bibliography.stub!(:match).with(failure).and_return({})
      @bibliography.stub!(:match).with(success).and_return({:source_url => 'source'})
      @importer.import
      @importer.processed_count.should == 2
      @importer.book_failure_count.should == 1
    end

    it "should record the number of failures because reference was to another source" do
      success = Factory :reference
      failure = Factory :unknown_reference
      @bibliography.stub!(:match).with(failure).and_return({})
      @bibliography.stub!(:match).with(success).and_return({:source_url => 'source'})
      @importer.import
      @importer.processed_count.should == 2
      @importer.unknown_reference_failure_count.should == 1
    end

    it "should record the number of failures because the PDF wasn't found" do
      success = Factory :reference
      failure = Factory :reference
      @bibliography.stub!(:match).with(failure).and_return({:source_url => 'success'})
      @bibliography.stub!(:match).with(success).and_return({:source_url => 'failure'})
      @importer.should_receive(:source_url_exists?).with('success').and_return(true)
      @importer.should_receive(:source_url_exists?).with('failure').and_return(false)
      @importer.import
      @importer.processed_count.should == 2
      @importer.pdf_not_found_failure_count.should == 1
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
