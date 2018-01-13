require "spec_helper"

describe References::DownloadsController do
  describe "GET show" do
    describe "reference without a document" do
      it "raises an error" do
        expect { get :show, params: { id: 99999, file_name: "not_even_stubbed.pdf" } }
          .to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe "reference with a document" do
      let!(:reference_document) { create :reference_document }

      context "with full access" do
        before do
          allow_any_instance_of(ReferenceDocument).to receive(:actual_url)
            .and_return "http://localhost/file.pdf"
          allow_any_instance_of(ReferenceDocument).to receive(:downloadable?).and_return true
        end

        it "redirects to the file" do
          response = get :show, params: { id: reference_document.id, file_name: "not_even_stubbed.pdf" }
          expect(response).to redirect_to reference_document.actual_url
        end
      end

      context "without access" do
        before do
          allow_any_instance_of(ReferenceDocument).to receive(:downloadable?).and_return false
        end

        it "redirects to the file" do
          response = get :show, params: { id: reference_document.id, file_name: "not_even_stubbed.pdf" }
          expect(response.response_code).to eq 401
        end
      end
    end
  end
end
