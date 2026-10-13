# frozen_string_literal: true

require 'rails_helper'

describe "Reference document uploads (multipart requests)" do
  let(:pdf) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test_pdf.pdf'), 'application/pdf') }

  before do
    sign_in create(:user, :helper)
  end

  it 'uploads a PDF from the reference form to S3 and links to it' do
    params = {
      reference_type: 'ArticleReference',
      reference: {
        title: 'Multipart Ants',
        year: 2001,
        author_names_string: "Batiatus, B.",
        pagination: '5',
        journal_name: 'Zootaxa',
        series_volume_issue: '6',
        document_attributes: { file: pdf }
      }
    }

    expect { post references_path, params: params }.to change { ReferenceDocument.count }.by(1)
    expect(request.content_type).to start_with 'multipart/form-data'

    document = ReferenceDocument.last
    expect(document.file_file_name).to eq 'test_pdf.pdf'
    expect(s3_requests(:put_object).first[:params]).to include(
      bucket: 'antcat_test',
      key: "#{document.id}/test_pdf.pdf",
      acl: 'authenticated-read',
      content_type: 'application/pdf'
    )

    get "/documents/#{document.id}/test_pdf.pdf"
    location = URI.parse(response.location)
    expect(response).to have_http_status :found
    expect(location.path).to eq "/antcat_test/#{document.id}/test_pdf.pdf"
  end

  describe 'pages with documents when S3 is not configured' do
    let!(:reference) { create :article_reference, :with_author_name }
    let!(:document) { ReferenceDocument.create!(reference: reference, file_file_name: 'test_pdf.pdf') }

    before do
      allow(Settings).to receive(:s3).and_return(unconfigured_s3_settings)
    end

    it 'still renders the reference and its edit form, and only the PDF link fails gracefully' do
      get reference_path(reference)
      expect(response).to have_http_status :ok
      expect(response.body).to include "/documents/#{document.id}/test_pdf.pdf"

      get edit_reference_path(reference)
      expect(response).to have_http_status :ok
      expect(response.body).to include 'type="file"'

      get "/documents/#{document.id}/test_pdf.pdf"
      expect(response).to have_http_status :service_unavailable
    end
  end
end
