require 'spec_helper'

describe ReferenceDocument do
  it "should make sure it has a protocol" do
    stub_request(:any, "http://antcat.org/1.pdf").to_return body: "Hello World!"
    document = create :reference_document
    document.url = 'antcat.org/1.pdf'
    document.save!
    expect(document.reload.url).to eq 'http://antcat.org/1.pdf'
    document.save!
    expect(document.reload.url).to eq 'http://antcat.org/1.pdf'
  end

  it "should make sure it's a valid URL" do
    document = ReferenceDocument.new url: '*'
    expect(document).not_to be_valid
    expect(document.errors.full_messages).to match_array ['Url is not in a valid format']
  end

  it "accepts URLs with spaces" do
    stub_request(:any, "http://antwiki.org/a%20url").to_return body: "Hello World!"
    document = ReferenceDocument.new url: 'http://antwiki.org/a url'
    expect(document).to be_valid
  end

  it "don't check existence of URL when it's ours" do
    document = ReferenceDocument.new url: 'http://antcat.org/a.pdf'
    expect(document).to be_valid
  end

  it "should make sure it's a valid URL with a path" do
    document = ReferenceDocument.new url: 'google.com'
    expect(document).not_to be_valid
    expect(document.errors.full_messages).to match_array ['Url is not in a valid format']
  end

  it "should make sure it exists" do
    stub_request(:any, "http://antwiki.org/1.pdf").to_return body: "Hello World!"
    document = ReferenceDocument.create url: 'http://antwiki.org/1.pdf'
    expect(document).to be_valid
    stub_request(:any, "http://antwiki.org/1.pdf").to_return body: "Not Found", status: 404
    expect(document).not_to be_valid
    expect(document.errors.full_messages).to match_array ['Url was not found']
  end

  it "creates the URL for an uploaded file so that it goes to our controller" do
    document = create :reference_document
    document.file_file_name = '1.pdf'
    document.host = 'antcat.org'
    expect(document.reload.url).to eq "http://antcat.org/documents/#{document.id}/1.pdf"
  end

  describe "#actual_url" do
    it "simply be the url, if the document's not on Amazon" do
      document = create :reference_document
      document.update_attribute :url, 'foo'
      expect(document.reload.actual_url).to eq 'foo'
    end
    #it "should go to Amazon, if necessary" do
      #document = create :reference_document
      #document.file_file_name = '1.pdf'
      #document.host = 'antcat.org'
      #document.reload.actual_url.should match /http:\/\/s3\.amazonaws\.com\/antcat\/#{document.id}\/1\.pdf\?AWSAccessKeyId=/
    #end
  end

  describe "#downloadable?" do
    it "should not be downloadable if there is no url" do
      expect(ReferenceDocument.new).not_to be_downloadable
    end

    it "is downloadable by anyone if we just have a URL, not a file name on S3" do
      expect(ReferenceDocument.new(url: 'foo')).to be_downloadable
    end

    it "is downloadable by just anyone if we are hosting on S3" do
      expect(ReferenceDocument.new(url: 'foo', file_file_name: 'bar')).to be_downloadable
    end

    it "is downloadable by a registered user if we are hosting on S3" do
      expect(ReferenceDocument.new(url: 'foo', file_file_name: 'bar')).to be_downloadable
    end

    it "is downloadable by anyone if it's public" do
      document = ReferenceDocument.new url: 'foo', file_file_name: 'bar', public: true
      expect(document).to be_downloadable
    end

    it "should not be downloadable if it is on http://128.146.250.117" do
      document = ReferenceDocument.new url: 'http://128.146.250.117/pdfs/4096/4096.pdf'
      expect(document).not_to be_downloadable
    end

    it "should not consider antbase PDFs downloadable by anybody" do
      url = 'http://antbase.org/ants/publications/4495/4495.pdf'
      document = ReferenceDocument.new url: url, file_file_name: 'bar'
      expect(document).not_to be_downloadable
    end
  end

  describe "#host=" do
    it "should do nothing if there is not file" do
      document = ReferenceDocument.new
      document.host = 'localhost'
      expect(document.url).to be_nil
    end

    it "should do nothing if the file isn't hosted by us" do
      document = ReferenceDocument.new url: 'foo'
      document.host = 'localhost'
      expect(document.url).to eq 'foo'
    end

    it "inserts the host in the url if the file is hosted by us" do
      document = ReferenceDocument.create! file_file_name: 'foo'
      document.host = 'localhost'
      expect(document.url).to eq "http://localhost/documents/#{document.id}/foo"
    end
  end

  describe "versioning" do
    it "records versions" do
      with_versioning do
        reference_document = create :reference_document
        expect(reference_document.versions.last.event).to eq 'create'
      end
    end
  end
end
