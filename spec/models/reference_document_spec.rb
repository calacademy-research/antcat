require 'rails_helper'

describe ReferenceDocument do
  it { is_expected.to be_versioned }

  describe 'validations' do
    it "validates URLs start with a protocol" do
      document = described_class.new(url: 'antwiki.org/url')
      expect(document.valid?).to eq false
    end

    it "validates the URL" do
      document = described_class.new(url: 'http://:::')
      expect(document.valid?).to eq false
      expect(document.errors.full_messages).to match_array ['Url is not in a valid format']
    end

    it "accepts URLs with spaces" do
      stub_request(:any, "http://antwiki.org/a%20url").to_return(body: "Hello World!")
      document = described_class.new(url: 'http://antwiki.org/a url')
      expect(document.valid?).to eq true
    end
  end

  describe "#routed_url" do
    it "creates the URL for an uploaded file so that it goes to our controller" do
      document = create :reference_document, file_file_name: '1.pdf'
      expect(document.reload.routed_url).to eq "http://antcat.org/documents/#{document.id}/1.pdf"
    end

    context "when there is no file" do
      let!(:document) { described_class.new }

      specify do
        expect(document.url).to eq nil
        expect(document.routed_url).to eq document.url
      end
    end

    context "when the file isn't hosted by us" do
      let(:document) { described_class.new(url: 'foo') }

      specify do
        expect(document.url).to eq 'foo'
        expect(document.routed_url).to eq 'foo'
      end
    end

    context "when the file is hosted by us" do
      let(:document) { described_class.create!(file_file_name: 'foo') }

      specify do
        expect(document.url).to eq nil
        expect(document.routed_url).to eq "http://antcat.org/documents/#{document.id}/foo"
      end
    end
  end

  describe "#actual_url" do
    let!(:document) { create :reference_document, url: 'http://localhost/document.pdf' }

    it "simply be the url, if the document's not on Amazon" do
      expect(document.reload.actual_url).to eq 'http://localhost/document.pdf'
    end
  end

  describe "#downloadable?" do
    it "is not downloadable if there is no url" do
      expect(described_class.new.downloadable?).to eq false
    end

    it "is downloadable by anyone if we just have a URL, not a file name on S3" do
      expect(described_class.new(url: 'foo').downloadable?).to eq true
    end

    it "is downloadable by just anyone if we are hosting on S3" do
      expect(described_class.new(url: 'foo', file_file_name: 'bar').downloadable?).to eq true
    end

    it "is downloadable by anyone if it's public" do
      document = described_class.new(url: 'foo', file_file_name: 'bar', public: true)
      expect(document.downloadable?).to eq true
    end

    it "is not downloadable if it is on http://128.146.250.117" do
      document = described_class.new(url: 'http://128.146.250.117/pdfs/4096/4096.pdf')
      expect(document.downloadable?).to eq false
    end

    it "doesn't consider antbase PDFs downloadable by anybody" do
      document = described_class.new(url: 'http://antbase.org/ants/publications/4495/4495.pdf')
      expect(document.downloadable?).to eq false
    end
  end
end
