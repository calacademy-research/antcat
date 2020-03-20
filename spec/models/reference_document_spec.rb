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
    context 'when reference has no `url` or `file_file_name`' do
      let(:reference_document) { described_class.new(url: "", file_file_name: '') }

      specify { expect(reference_document.downloadable?).to eq false }
    end

    context 'when reference has a `file_file_name`' do
      let(:reference_document) { described_class.new(url: "", file_file_name: 'file.pdf') }

      specify { expect(reference_document.downloadable?).to eq true }
    end

    context 'when reference has a `url`' do
      let(:reference_document) { described_class.new(url: "http://ancat.org/file.pdf", file_file_name: '') }

      specify { expect(reference_document.downloadable?).to eq true }
    end
  end
end
