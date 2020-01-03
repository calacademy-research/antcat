require 'rails_helper'

describe ReferenceDocument do
  it { is_expected.to be_versioned }

  it "makes sure it has a protocol" do
    stub_request(:any, "http://antcat.org/1.pdf").to_return body: "Hello World!"
    document = create :reference_document
    document.url = 'antcat.org/1.pdf'
    document.save!
    expect(document.reload.url).to eq 'http://antcat.org/1.pdf'
    document.save!
    expect(document.reload.url).to eq 'http://antcat.org/1.pdf'
  end

  it "validates the URL" do
    document = described_class.new(url: ':::')
    expect(document).not_to be_valid
    expect(document.errors.full_messages).to match_array ['Url is not in a valid format']
  end

  it "accepts URLs with spaces" do
    stub_request(:any, "http://antwiki.org/a%20url").to_return body: "Hello World!"
    document = described_class.new(url: 'http://antwiki.org/a url')
    expect(document).to be_valid
  end

  it "creates the URL for an uploaded file so that it goes to our controller" do
    document = create :reference_document
    document.file_file_name = '1.pdf'
    document.host = 'antcat.org'
    expect(document.reload.url).to eq "http://antcat.org/documents/#{document.id}/1.pdf"
  end

  describe "#actual_url" do
    let!(:document) { create :reference_document, url: 'localhost/document.pdf' }

    it "simply be the url, if the document's not on Amazon" do
      expect(document.reload.actual_url).to eq 'http://localhost/document.pdf'
    end
  end

  describe "#downloadable?" do
    it "is not downloadable if there is no url" do
      expect(described_class.new).not_to be_downloadable
    end

    it "is downloadable by anyone if we just have a URL, not a file name on S3" do
      expect(described_class.new(url: 'foo')).to be_downloadable
    end

    it "is downloadable by just anyone if we are hosting on S3" do
      expect(described_class.new(url: 'foo', file_file_name: 'bar')).to be_downloadable
    end

    it "is downloadable by anyone if it's public" do
      document = described_class.new(url: 'foo', file_file_name: 'bar', public: true)
      expect(document).to be_downloadable
    end

    it "is not downloadable if it is on http://128.146.250.117" do
      document = described_class.new(url: 'http://128.146.250.117/pdfs/4096/4096.pdf')
      expect(document).not_to be_downloadable
    end

    it "doesn't consider antbase PDFs downloadable by anybody" do
      url = 'http://antbase.org/ants/publications/4495/4495.pdf'
      document = described_class.new(url: url, file_file_name: 'bar')
      expect(document).not_to be_downloadable
    end
  end

  describe "#host=" do
    context "when there is no file" do
      let!(:document) { described_class.new }

      it "does nothing" do
        document.host = 'localhost'
        expect(document.url).to eq nil
      end
    end

    context "when the file isn't hosted by us" do
      let(:document) { described_class.new(url: 'foo') }

      it "does nothing" do
        document.host = 'localhost'
        expect(document.url).to eq 'foo'
      end
    end

    context "when the file is hosted by us" do
      let(:document) { described_class.create!(file_file_name: 'foo') }

      it "inserts the host in the url" do
        document.host = 'localhost'
        expect(document.url).to eq "http://localhost/documents/#{document.id}/foo"
      end
    end
  end
end
