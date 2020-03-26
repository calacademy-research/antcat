# frozen_string_literal: true

require 'rails_helper'

describe References::DownloadsController do
  describe "GET show", as: :visitor do
    context "when reference document is downloadable" do
      let!(:reference_document) { create :reference_document, url: "http://localhost/file.pdf" }

      it "redirects to the file" do
        get :show, params: { id: reference_document.id, file_name: "not_even_stubbed.pdf" }
        expect(response).to redirect_to reference_document.actual_url
      end
    end

    context "when reference document is not downloadable" do
      let!(:reference_document) { create :reference_document }

      it "redirects to the file" do
        get :show, params: { id: reference_document.id, file_name: "not_even_stubbed.pdf" }
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
