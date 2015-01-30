# coding: UTF-8
require 'spec_helper'

describe Importers::Hol::DocumentUrlImporter do
  before do
    stub_request(:any, "http://url.com/foo").to_return :body => "Hello World!"
    @matcher = double Importers::Hol::ReferenceMatcher
    allow(Importers::Hol::ReferenceMatcher).to receive(:new).and_return @matcher
    @importer = Importers::Hol::DocumentUrlImporter.new
    @hol_reference = Hol::Reference.new :document_url => 'url.com/foo'
  end

  describe "importing document URL for all references" do
    it "should do nothing if there are no references" do
      @importer.import
    end

    it "should import each reference" do
      mocks = [mock_model(Reference), mock_model(Reference)]
      allow(Reference).to receive(:sorted_by_principal_author_last_name).and_return mocks
      mocks.each {|mock| expect(@importer).to receive(:import_document_url_for).with(mock).and_return 'asdf'}
      @importer.import
    end

    it "should not try to import if it already has a document" do
      no_document_url = FactoryGirl.create :reference
      with_document_url = FactoryGirl.create :reference, :document => FactoryGirl.create(:reference_document, :url => 'url.com/foo')
      expect(@matcher).to receive(:match).with(no_document_url).and_return @hol_reference
      expect(@matcher).not_to receive(:match).with(with_document_url)
      @importer.import
      expect(@importer.processed_count).to eq(2)
      expect(@importer.success_count).to eq(2)
      expect(@importer.already_imported_count).to eq(1)
    end

    it "should import references in order of their first author" do
      Reference.delete_all
      bolton = FactoryGirl.create :author_name, :name => 'Bolton'
      ward = FactoryGirl.create :author_name, :name => 'Ward'
      fisher = FactoryGirl.create :author_name, :name => 'Fisher'
      bolton_reference = FactoryGirl.create :reference, :author_names => [bolton]
      ward_reference = FactoryGirl.create :reference, :author_names => [ward]
      fisher_reference = FactoryGirl.create :reference, :author_names => [fisher]

      expect(@importer).to receive(:import_document_url_for).with(bolton_reference).ordered.and_return 'asdf'
      expect(@importer).to receive(:import_document_url_for).with(fisher_reference).ordered.and_return 'asdf'
      expect(@importer).to receive(:import_document_url_for).with(ward_reference).ordered.and_return 'asdf'

      @importer.import
    end
  end

  describe "saving the authors it can't find" do
    it "should save the authors it can't find" do
      bolton_reference = FactoryGirl.create :reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Bolton')]
      ward_reference = FactoryGirl.create :reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Ward')]
      fisher = FactoryGirl.create :author_name, :name => 'Fisher'
      fisher_reference = FactoryGirl.create :reference, :author_names => [fisher]
      another_fisher_reference = FactoryGirl.create :reference, :author_names => [fisher]
      allow(@matcher).to receive(:match).with(bolton_reference).and_return @hol_reference
      allow(@matcher).to receive(:match).with(ward_reference).and_return @hol_reference
      allow(@matcher).to receive(:match).with(fisher_reference).and_return :no_entries_for_author
      allow(@matcher).to receive(:match).with(another_fisher_reference).and_return :no_entries_for_author
      @importer.import
      expect(@importer.missing_authors).to eq(['Fisher'])
      expect(@importer.missing_author_count).to eq(2)
    end
  end

  describe "recording counts of successful imports and each kind of failure" do
    it "should record the number of successful and unsuccessful imports" do
      success = FactoryGirl.create :reference
      failure = FactoryGirl.create :reference
      allow(@matcher).to receive(:match).with(failure).and_return nil
      allow(@matcher).to receive(:match).with(success).and_return @hol_reference
      @importer.import
      expect(@importer.processed_count).to eq(2)
      expect(@importer.success_count).to eq(1)
    end

    it "should record the number of failures because reference was to a book" do
      success = FactoryGirl.create :reference
      failure = FactoryGirl.create :book_reference
      allow(@matcher).to receive(:match).with(failure).and_return :book_reference
      allow(@matcher).to receive(:match).with(success).and_return @hol_reference
      @importer.import
      expect(@importer.processed_count).to eq(2)
      expect(@importer.book_failure_count).to eq(1)
    end

    it "should record the number of failures because reference was to another document" do
      success = FactoryGirl.create :reference
      failure = FactoryGirl.create :unknown_reference
      allow(@matcher).to receive(:match).with(failure).and_return nil
      allow(@matcher).to receive(:match).with(success).and_return @hol_reference
      @importer.import
      expect(@importer.processed_count).to eq(2)
      expect(@importer.unknown_count).to eq(1)
    end

    it "should record the number of failures because the PDF wasn't found" do
      success = FactoryGirl.create :reference
      failure = FactoryGirl.create :reference
      allow(@matcher).to receive(:match).with(failure).and_return Hol::Reference.new(:document_url => 'url.com/bar')
      stub_request(:any, "http://url.com/bar").to_return :status => 404
      allow(@matcher).to receive(:match).with(success).and_return Hol::Reference.new(:document_url => 'url.com/foo')
      stub_request(:any, "http://url.com/foo").to_return :status => 200
      @importer.import
      expect(@importer.processed_count).to eq(2)
      expect(@importer.pdf_not_found_count).to eq(1)
    end
  end

  describe "importing document URL for one reference" do

    it "save the url" do
      reference = FactoryGirl.create :reference
      allow(@matcher).to receive(:match).with(reference).and_return Hol::Reference.new(:document_url => 'url.com/foo')
      @importer.import_document_url_for reference
      expect(reference.reload.document(true).url).to eq('http://url.com/foo')
    end

  end
end
