# coding: UTF-8
require 'spec_helper'

describe Hol::DocumentUrlImporter do
  before do
    stub_request(:any, "http://url.com/foo").to_return :body => "Hello World!"
    @matcher = mock Hol::ReferenceMatcher
    Hol::ReferenceMatcher.stub!(:new).and_return @matcher
    @importer = Hol::DocumentUrlImporter.new
    @hol_reference = Hol::Reference.new :document_url => 'url.com/foo'
  end

  describe "importing document URL for all references" do
    it "should do nothing if there are no references" do
      @importer.import
    end

    it "should import each reference" do
      mocks = [mock_model(Reference), mock_model(Reference)]
      Reference.stub!(:sorted_by_principal_author_last_name).and_return mocks
      mocks.each {|mock| @importer.should_receive(:import_document_url_for).with(mock).and_return 'asdf'}
      @importer.import
    end

    it "should not try to import if it already has a document" do
      no_document_url = Factory :reference
      with_document_url = Factory :reference, :document => Factory(:reference_document, :url => 'url.com/foo')
      @matcher.should_receive(:match).with(no_document_url).and_return @hol_reference
      @matcher.should_not_receive(:match).with(with_document_url)
      @importer.import
      @importer.processed_count.should == 2
      @importer.success_count.should == 2
      @importer.already_imported_count.should == 1
    end

    it "should import references in order of their first author" do
      Reference.delete_all
      bolton = Factory :author_name, :name => 'Bolton'
      ward = Factory :author_name, :name => 'Ward'
      fisher = Factory :author_name, :name => 'Fisher'
      bolton_reference = Factory :reference, :author_names => [bolton]
      ward_reference = Factory :reference, :author_names => [ward]
      fisher_reference = Factory :reference, :author_names => [fisher]

      @importer.should_receive(:import_document_url_for).with(bolton_reference).ordered.and_return 'asdf'
      @importer.should_receive(:import_document_url_for).with(fisher_reference).ordered.and_return 'asdf'
      @importer.should_receive(:import_document_url_for).with(ward_reference).ordered.and_return 'asdf'

      @importer.import
    end
  end

  describe "saving the authors it can't find" do
    it "should save the authors it can't find" do
      bolton_reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Bolton')]
      ward_reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Ward')]
      fisher = Factory :author_name, :name => 'Fisher'
      fisher_reference = Factory :reference, :author_names => [fisher]
      another_fisher_reference = Factory :reference, :author_names => [fisher]
      @matcher.stub!(:match).with(bolton_reference).and_return @hol_reference
      @matcher.stub!(:match).with(ward_reference).and_return @hol_reference
      @matcher.stub!(:match).with(fisher_reference).and_return :no_entries_for_author
      @matcher.stub!(:match).with(another_fisher_reference).and_return :no_entries_for_author
      @importer.import
      @importer.missing_authors.should == ['Fisher']
      @importer.missing_author_count.should == 2
    end
  end

  describe "recording counts of successful imports and each kind of failure" do
    it "should record the number of successful and unsuccessful imports" do
      success = Factory :reference
      failure = Factory :reference
      @matcher.stub!(:match).with(failure).and_return nil
      @matcher.stub!(:match).with(success).and_return @hol_reference
      @importer.import
      @importer.processed_count.should == 2
      @importer.success_count.should == 1
    end

    it "should record the number of failures because reference was to a book" do
      success = Factory :reference
      failure = Factory :book_reference
      @matcher.stub!(:match).with(failure).and_return :book_reference
      @matcher.stub!(:match).with(success).and_return @hol_reference
      @importer.import
      @importer.processed_count.should == 2
      @importer.book_failure_count.should == 1
    end

    it "should record the number of failures because reference was to another document" do
      success = Factory :reference
      failure = Factory :unknown_reference
      @matcher.stub!(:match).with(failure).and_return nil
      @matcher.stub!(:match).with(success).and_return @hol_reference
      @importer.import
      @importer.processed_count.should == 2
      @importer.unknown_count.should == 1
    end

    it "should record the number of failures because the PDF wasn't found" do
      success = Factory :reference
      failure = Factory :reference
      @matcher.stub!(:match).with(failure).and_return Hol::Reference.new(:document_url => 'url.com/bar')
      stub_request(:any, "http://url.com/bar").to_return :status => 404
      @matcher.stub!(:match).with(success).and_return Hol::Reference.new(:document_url => 'url.com/foo')
      stub_request(:any, "http://url.com/foo").to_return :status => 200
      @importer.import
      @importer.processed_count.should == 2
      @importer.pdf_not_found_count.should == 1
    end
  end

  describe "importing document URL for one reference" do

    it "save the url" do
      reference = Factory :reference 
      @matcher.stub!(:match).with(reference).and_return Hol::Reference.new(:document_url => 'url.com/foo')
      @importer.import_document_url_for reference 
      reference.reload.document(true).url.should == 'http://url.com/foo'
    end

  end
end
