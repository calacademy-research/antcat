require 'spec_helper'

describe Document do
  it "should make sure it has a protocol" do
    stub_request(:any, "http://antcat.org/1.pdf").to_return :body => "Hello World!"
    document = Factory :document
    document.url = 'antcat.org/1.pdf'
    document.save!
    document.reload.url.should == 'http://antcat.org/1.pdf'
    document.save!
    document.reload.url.should == 'http://antcat.org/1.pdf'
  end

  it "should make sure it's a valid URL" do
    document = Document.new :url => '*'
    document.should_not be_valid
    document.errors.full_messages.should =~ ['Url is not in a valid format']
  end

  it "should make sure it's a valid URL with a path" do
    document = Document.new :url => 'google.com'
    document.should_not be_valid
    document.errors.full_messages.should =~ ['Url is not in a valid format']
  end

  it "should make sure it exists" do
    stub_request(:any, "http://antbase.org/1.pdf").to_return :body => "Hello World!"
    document = Document.create :url => 'http://antbase.org/1.pdf'
    document.should be_valid
    stub_request(:any, "http://antbase.org/1.pdf").to_return :body => "Not Found", :status => 404
    document.should_not be_valid
    document.errors.full_messages.should =~ ['Url was not found']
  end

  it "should say that it's not hosted by us when the URL is blank" do
    document = Factory :document
    document.should_not be_hosted_by_us
  end

  it "should know when it's not hosted by us" do
    document = Factory :document
    document.url = 'http://antbase.org/pdfs/23/3242.pdf'
    document.should_not be_hosted_by_us
  end

  it "should know when it is hosted by S3" do
    document = Factory :document
    document.update_attribute :file_file_name, '1.pdf'
    document.should be_hosted_by_us
  end

  it "should create the URL for an uploaded file so that it goes to our controller" do
    document = Factory :document
    document.file_file_name = '1.pdf'
    document.set_uploaded_url 'antcat.org'
    document.reload.url.should == "http://antcat.org/files/#{document.id}/1.pdf"
  end

  describe "authenticated_url" do
    it "should go to Amazon" do
      document = Factory :document
      document.file_file_name = '1.pdf'
      document.set_uploaded_url 'antcat.org'
      document.reload.authenticated_url.should match /http:\/\/s3\.amazonaws\.com\/antcat\/files\/#{document.id}\/1\.pdf\?AWSAccessKeyId=/
    end
  end

end
