# frozen_string_literal: true

require 'rails_helper'

describe ReferenceDocument do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:reference).required }
  end

  describe 'validations' do
    it { is_expected.to validate_absence_of(:url).on(:create) }

    describe '`url` format (on update)' do
      let(:document) { create :reference_document, :with_reference, :with_deprecated_url }

      it 'allows http and https URLs' do
        expect(document.update(url: 'https://example.com/a.pdf')).to eq true
        expect(document.update(url: 'HTTP://example.com/a.pdf')).to eq true
      end

      it 'rejects other URLs' do
        bad_urls = [
          'javascript:alert(1)', 'JavaScript:alert(1)', 'data:text/html,x', 'example.com/a.pdf',
          "https://example.com/\njavascript:x", '//example.com/a.pdf'
        ]
        bad_urls.each do |url|
          expect(document.update(url: url)).to eq(false), url
          expect(document.errors[:url]).to include "must start with http:// or https://"
        end
      end
    end

    describe '#ensure_file_or_url_present' do
      context 'when `url` and `file_file_name` are both blank' do
        let(:document) { described_class.new(url: nil, file_file_name: nil) }

        specify do
          expect(document.valid?).to eq false
          expect(document.errors.full_messages).to include "URL and uploaded file cannot both be blank"
        end
      end

      context 'when `url` and `file_file_name` are both present' do
        let(:document) { described_class.new(url: "http://ancat.org/file.pdf", file_file_name: 'file.pdf') }

        specify do
          expect(document.valid?).to eq false
          expect(document.errors.full_messages).to include "URL and uploaded file cannot both be present"
        end
      end
    end
  end

  describe '.with_non_http_url' do
    let!(:http_document) { create :reference_document, :with_reference, :with_deprecated_url }
    let!(:bad_document) { create :reference_document, :with_reference, :with_deprecated_url }

    before do
      create :reference_document, :with_reference, :with_file
      bad_document.update_column(:url, 'javascript:alert(1)')
    end

    it 'returns only documents with a `url` that is not http(s)' do
      expect(described_class.with_non_http_url).to eq [bad_document]
      expect(described_class.with_non_http_url).not_to include http_document
    end
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:url) }
  end

  describe "#routed_url" do
    it "creates the URL for an uploaded file so that it goes to our controller" do
      document = create :reference_document, :with_reference, file_file_name: '1.pdf'
      expect(document.routed_url).to eq "http://antcat_test.localhost/documents/#{document.id}/1.pdf"
    end

    context "when the file isn't hosted by us" do
      let(:document) { described_class.new(url: 'https://example.com/foo.pdf') }

      specify do
        expect(document.url).to eq 'https://example.com/foo.pdf'
        expect(document.routed_url).to eq 'https://example.com/foo.pdf'
      end
    end

    context "when the legacy `url` is not http(s) (data from before the validation)" do
      let(:document) { described_class.new(url: 'javascript:alert(1)') }

      specify do
        expect(document.routed_url).to eq nil
        expect(document.actual_url).to eq nil
      end
    end

    context "when the file is hosted by us" do
      let(:document) { described_class.create!(file_file_name: 'foo', reference: create(:any_reference)) }

      specify do
        expect(document.url).to eq nil
        expect(document.routed_url).to eq "http://antcat_test.localhost/documents/#{document.id}/foo"
      end
    end
  end

  describe "#file=" do
    let(:reference) { create :any_reference }

    def uploaded_pdf original_filename
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec/fixtures/test_pdf.pdf'), 'application/pdf', true, original_filename: original_filename
      )
    end

    it 'sets `file_file_name` from the original file name' do
      document = described_class.new(file: uploaded_pdf('test_pdf.pdf'))
      expect(document.file_file_name).to eq 'test_pdf.pdf'
    end

    it 'transliterates the file name like Paperclip did' do
      document = described_class.new(file: uploaded_pdf('Fisher & Bolton Ménage.PDF'))
      expect(document.file_file_name).to eq 'fisher___bolton_menage.pdf'
    end

    it 'handles extensions with regular expression characters' do
      expect { described_class.new(file: uploaded_pdf('x.(')) }.not_to raise_error
      expect(described_class.new(file: uploaded_pdf('a.b*')).file_file_name).to eq 'a.b'
    end

    it 'uses the basename of a `File`' do
      document = described_class.new(file: File.new(Rails.root.join('spec/fixtures/test_pdf.pdf')))
      expect(document.file_file_name).to eq 'test_pdf.pdf'
    end

    it 'ignores blank values (empty file fields)' do
      document = described_class.new(file_file_name: 'old.pdf')
      document.file = ''
      expect(document.file_file_name).to eq 'old.pdf'
      expect(document.file).to eq nil
    end

    describe 'uploading to S3' do
      it 'uploads the file after create, with the same key, ACL and bucket as Paperclip' do
        document = described_class.create!(reference: reference, file: uploaded_pdf('test_pdf.pdf'))

        put_requests = s3_requests(:put_object)
        expect(put_requests.size).to eq 1
        expect(put_requests.first[:params]).to include(
          bucket: 'antcat_test',
          key: "#{document.id}/test_pdf.pdf",
          acl: 'authenticated-read',
          content_type: 'application/pdf'
        )
        expect(document.file).to eq nil
      end

      it 'uploads to the transliterated key' do
        document = described_class.create!(reference: reference, file: uploaded_pdf('Fisher & Bolton Ménage.PDF'))
        expect(s3_requests(:put_object).first[:params][:key]).to eq "#{document.id}/fisher___bolton_menage.pdf"
      end

      it 'detects the content type from the file, not the declared type' do
        upload = Rack::Test::UploadedFile.new(
          Rails.root.join('spec/fixtures/test_pdf.pdf'), 'application/octet-stream', true, original_filename: 'x.pdf'
        )
        described_class.create!(reference: reference, file: upload)
        expect(s3_requests(:put_object).first[:params][:content_type]).to eq 'application/pdf'
      end

      it 'uploads a replacement file and never deletes old objects' do
        document = described_class.create!(reference: reference, file: uploaded_pdf('first.pdf'))
        document.update!(file: uploaded_pdf('second.pdf'))

        expect(s3_requests(:put_object).map { |request| request[:params][:key] }).
          to eq ["#{document.id}/first.pdf", "#{document.id}/second.pdf"]
        expect(s3_requests(:delete_object)).to be_empty
        expect(document.reload.file_file_name).to eq 'second.pdf'
      end

      it 'uploads a replacement file with the same name' do
        document = described_class.create!(reference: reference, file: uploaded_pdf('same.pdf'))
        document.update!(file: uploaded_pdf('same.pdf'))
        expect(s3_requests(:put_object).size).to eq 2
      end

      it 'does not upload anything when no file is assigned' do
        described_class.create!(reference: reference, file_file_name: 'existing.pdf')
        expect(s3_requests(:put_object)).to be_empty
      end

      it 'does not delete the object when the document is destroyed' do
        document = described_class.create!(reference: reference, file: uploaded_pdf('test_pdf.pdf'))
        document.destroy!
        expect(s3_requests(:delete_object)).to be_empty
      end

      it 'does not upload or save when validations fail' do
        document = described_class.new(reference: reference, file: uploaded_pdf('test_pdf.pdf'), url: 'http://example.com')
        expect(document.save).to eq false
        expect(s3_requests(:put_object)).to be_empty
      end
    end
  end

  describe "#actual_url" do
    context 'with file (on S3)' do
      let(:reference_document) { create :reference_document, :with_reference, :with_file }

      it 'links to S3' do
        expect(reference_document.actual_url).
          to include "https://s3.amazonaws.com/antcat_test/#{reference_document.id}"
      end

      it 'is a presigned GET URL for the bucket and key, expiring in one day' do
        uri = URI.parse(reference_document.actual_url)
        query = Rack::Utils.parse_query(uri.query)

        expect(uri.scheme).to eq 'https'
        expect(uri.host).to eq 's3.amazonaws.com'
        expect(uri.path).to eq "/antcat_test/#{reference_document.id}/test_pdf.pdf"
        expect(query['X-Amz-Expires']).to eq '86400'
        expect(query['X-Amz-Algorithm']).to eq 'AWS4-HMAC-SHA256'
        expect(query['X-Amz-Credential']).to start_with 'pizza/'
        expect(query['X-Amz-Signature']).to be_present
      end
    end

    context 'with an existing row with a file (uploaded by Paperclip)' do
      let(:reference_document) do
        described_class.create!(reference: create(:any_reference), file_file_name: 'Old Name (1999).pdf')
      end

      it 'links to the existing S3 object without uploading anything' do
        uri = URI.parse(reference_document.actual_url)
        expect(uri.path).to eq "/antcat_test/#{reference_document.id}/Old%20Name%20%281999%29.pdf"
        expect(s3_requests(:put_object)).to be_empty
      end
    end

    context 'with `url` (no file)' do
      let!(:reference_document) { create :reference_document, :with_reference, :with_deprecated_url }

      it "simply is the `url`" do
        expect(reference_document.actual_url).to eq reference_document.url
      end

      it 'works without S3 settings' do
        allow(Settings).to receive(:s3).and_return(unconfigured_s3_settings)
        expect(reference_document.actual_url).to eq reference_document.url
      end
    end

    context 'when S3 is not configured (for example on a staging server without S3 keys)' do
      let!(:reference_document) do
        described_class.create!(reference: create(:any_reference), file_file_name: 'test_pdf.pdf')
      end

      before do
        allow(Settings).to receive(:s3).and_return(unconfigured_s3_settings)
      end

      it 'raises `NotConfigured` only when the S3 link is needed' do
        expect(reference_document.routed_url).to eq "http://antcat_test.localhost/documents/#{reference_document.id}/test_pdf.pdf"
        expect { reference_document.actual_url }.to raise_error References::DocumentStorage::NotConfigured
      end
    end
  end
end
