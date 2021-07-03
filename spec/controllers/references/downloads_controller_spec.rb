# frozen_string_literal: true

require 'rails_helper'

describe References::DownloadsController do
  describe "GET show", as: :visitor do
    context "when reference document is downloadable" do
      let!(:reference_document) { create :reference_document, :with_file }

      it "redirects to the file" do
        get :show, params: { id: reference_document.id, file_name: "not_even_stubbed.pdf" }
        expect(response).to redirect_to reference_document.actual_url
      end
    end
  end
end
