# coding: UTF-8
require 'spec_helper'

describe ReferenceDocument do
  it "should make sure it has a protocol" do
    stub_request(:any, "http://antcat.org/1.pdf").to_return :body => "Hello World!"
    document = Factory :reference_document
    document.url = 'antcat.org/1.pdf'
    document.save!
    document.reload.url.should == 'http://antcat.org/1.pdf'
    document.save!
    document.reload.url.should == 'http://antcat.org/1.pdf'
  end

  it "should make sure it's a valid URL" do
    document = ReferenceDocument.new :url => '*'
    document.should_not be_valid
    document.errors.full_messages.should =~ ['Url is not in a valid format']
  end

  it "should accept a URL with spaces" do
    stub_request(:any, "http://antbase.org/a%20url").to_return :body => "Hello World!"
    document = ReferenceDocument.new :url => 'http://antbase.org/a url'
    document.should be_valid
  end

  it "don't check existence of URL when it's ours" do
    document = ReferenceDocument.new :url => 'http://antcat.org/a.pdf'
    document.should be_valid
  end

  it "should make sure it's a valid URL with a path" do
    document = ReferenceDocument.new :url => 'google.com'
    document.should_not be_valid
    document.errors.full_messages.should =~ ['Url is not in a valid format']
  end

  it "should make sure it exists" do
    stub_request(:any, "http://antbase.org/1.pdf").to_return :body => "Hello World!"
    document = ReferenceDocument.create :url => 'http://antbase.org/1.pdf'
    document.should be_valid
    stub_request(:any, "http://antbase.org/1.pdf").to_return :body => "Not Found", :status => 404
    document.should_not be_valid
    document.errors.full_messages.should =~ ['Url was not found']
  end

  it "should create the URL for an uploaded file so that it goes to our controller" do
    document = Factory :reference_document
    document.file_file_name = '1.pdf'
    document.host = 'antcat.org'
    document.reload.url.should == "http://antcat.org/documents/#{document.id}/1.pdf"
  end

  describe "actual url" do
    it "simply be the url, if the document's not on Amazon" do
      document = Factory :reference_document
      document.update_attribute :url, 'foo'
      document.reload.actual_url.should == 'foo'
    end
    it "should go to Amazon, if necessary" do
      document = Factory :reference_document
      document.file_file_name = '1.pdf'
      document.host = 'antcat.org'
      document.reload.actual_url.should match /http:\/\/s3\.amazonaws\.com\/antcat\/#{document.id}\/1\.pdf\?AWSAccessKeyId=/
    end
  end

  describe "downloadable_by?" do
    before do
      @user = Factory :user
    end
    it "should not be downloadable if there is no url" do
      ReferenceDocument.new.should_not be_downloadable_by @user
    end
    it "should be downloadable by anyone if we just have a URL, not a file name on S3" do
      ReferenceDocument.new(:url => 'foo').should be_downloadable_by nil
    end
    it "should not be downloadable by just anyone if we are hosting on S3" do
      ReferenceDocument.new(:url => 'foo', :file_file_name => 'bar').should_not be_downloadable_by nil
    end
    it "should be downloadable by a registered user if we are hosting on S3" do
      ReferenceDocument.new(:url => 'foo', :file_file_name => 'bar').should be_downloadable_by Factory :user
    end
    it "should be downloadable by anyone if it's public" do
      document = ReferenceDocument.new(:url => 'foo', :file_file_name => 'bar', :public => true)
      document.should be_downloadable_by Factory :user
      document.should be_downloadable_by nil
    end
  end

  describe "setting the host" do
    it "should do nothing if there is not file" do
      document = ReferenceDocument.new
      document.host = 'localhost'
      document.url.should be_nil
    end

    it "should do nothing if the file isn't hosted by us" do
      document = ReferenceDocument.new :url => 'foo'
      document.host = 'localhost'
      document.url.should == 'foo'
    end

    it "should insert the host in the url if the file is hosted by us" do
      document = ReferenceDocument.create! :file_file_name => 'foo'
      document.host = 'localhost'
      document.url.should == "http://localhost/documents/#{document.id}/foo"
    end

  end

end
