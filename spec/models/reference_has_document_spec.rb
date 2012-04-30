# coding: UTF-8
require 'spec_helper'

describe Reference do

  describe "document" do
    it "has a document" do
      reference = FactoryGirl.create :reference
      reference.document.should be_nil
      reference.create_document
      reference.document.should_not be_nil
    end
  end

  describe "downloadable_by?" do
    it "should be false if there is no document" do
      FactoryGirl.create(:reference).should_not be_downloadable_by FactoryGirl.create :user
    end

    it "should delegate to its document" do
      reference = FactoryGirl.create :reference, :document => FactoryGirl.create(:reference_document)
      user = FactoryGirl.create :user
      reference.document.should_receive(:downloadable_by?).with(user)
      reference.downloadable_by? user
    end
  end

  describe "url" do
    it "should be nil if there is no document" do
      FactoryGirl.create(:reference).url.should be_nil
    end
    it "should delegate to its document" do
      reference = FactoryGirl.create :reference, :document => FactoryGirl.create(:reference_document)
      reference.document.should_receive(:url)
      reference.url
    end

    it "should make sure it exists" do
      reference = FactoryGirl.create :reference, :year => 2001
      stub_request(:any, "http://antwiki.org/1.pdf").to_return :body => "Not Found", :status => 404
      lambda {reference.document = ReferenceDocument.create :url => 'http://antwiki.org/1.pdf'}.should raise_error ActiveRecord::RecordNotSaved
    end

  end

  describe "setting the document host" do
    it "should not crash if there is no document" do
      FactoryGirl.create(:reference).document_host = 'localhost'
    end
    it "should delegate to its document" do
      reference = FactoryGirl.create :reference, :document => FactoryGirl.create(:reference_document)
      reference.document.should_receive(:host=)
      reference.document_host = 'localhost'
    end
  end

end
