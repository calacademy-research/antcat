# frozen_string_literal: true

require 'rails_helper'

describe References::DownloadsController do
  describe "GET show", as: :visitor do
    context 'with a document on S3' do
      let!(:reference_document) { create :reference_document, :with_reference, :with_file }

      it "redirects to a presigned S3 URL" do
        get :show, params: { id: reference_document.id, file_name: "not_even_stubbed.pdf" }

        expect(response).to have_http_status :found
        location = URI.parse(response.location)
        expect(location.host).to eq 's3.amazonaws.com'
        expect(location.path).to eq "/antcat_test/#{reference_document.id}/test_pdf.pdf"
        expect(Rack::Utils.parse_query(location.query)['X-Amz-Expires']).to eq '86400'
      end

      context 'when S3 is not configured' do
        before do
          allow(Settings).to receive(:s3).and_return(unconfigured_s3_settings)
        end

        it "responds with 503 instead of raising" do
          get :show, params: { id: reference_document.id, file_name: "test_pdf.pdf" }

          expect(response).to have_http_status :service_unavailable
          expect(response.body).to include "not available on this server"
        end
      end
    end

    context 'with a url-only document' do
      let!(:reference_document) { create :reference_document, :with_reference, :with_deprecated_url }

      it "redirects to the `url`" do
        get :show, params: { id: reference_document.id, file_name: "document.pdf" }
        expect(response).to redirect_to 'http://localhost/document.pdf'
      end
    end

    context 'with a url-only document whose `url` is not http(s) (data from before the validation)' do
      let!(:reference_document) { create :reference_document, :with_reference, :with_deprecated_url }

      before { reference_document.update_column(:url, 'javascript:alert(1)') }

      it "does not redirect" do
        get :show, params: { id: reference_document.id, file_name: "document.pdf" }
        expect(response).to have_http_status :not_found
      end
    end
  end
end
