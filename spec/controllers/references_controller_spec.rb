require 'spec_helper'

describe ReferencesController do
  describe "GET index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template :index
    end

    it "assigns @references" do
      reference = create :article_reference
      get :index
      expect(assigns(:references)).to eq [reference]
    end
  end

  describe "GET search" do
    describe "search terms matching ids" do
      it "redirects to #show" do
        reference = reference_factory author_name: 'E.O. Wilson', id: 99999
        get :search, q: reference.id
        expect(response).to redirect_to reference_path(reference)
      end

      it "does not redirect unless the reference exists" do
        get :search, q: "11111"
        expect(response).to render_template "search"
      end
    end
  end

  describe "GET download" do
    describe "reference without a document" do
      it "raises an error" do
        expect { get :download, id: 99999, file_name: "not_even_stubbed.pdf" }
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
          response = get :download, id: reference_document.id, file_name: "not_even_stubbed.pdf"
          expect(response).to redirect_to reference_document.actual_url
        end
      end

      context "without access" do
        before do
          allow_any_instance_of(ReferenceDocument).to receive(:downloadable?).and_return false
        end

        it "redirects to the file" do
          response = get :download, id: reference_document.id, file_name: "not_even_stubbed.pdf"
          expect(response.response_code).to eq 401
        end
      end
    end
  end

  # TODO move specs to services' specs.
  describe "GET autocomplete", search: true do
    let(:controller) { ReferencesController.new }

    it "autocompletes" do
      reference_factory author_name: 'E.O. Wilson'
      reference_factory author_name: 'Bolton'
      Sunspot.commit

      get :autocomplete, q: "wilson", format: :json
      json = JSON.parse response.body

      expect(json.first["author"]).to eq 'E.O. Wilson'
      expect(json.size).to eq 1
    end

    it "only autocompletes if there's matches", search: true do
      get :autocomplete, q: "willy", format: :json
      json = JSON.parse response.body
      expect(json.size).to eq 0
    end

    describe "author queries not wrapped in quotes" do
      it "handles queries containing non-English characters" do
        reference_factory author_name: 'Bert Hölldobler'
        Sunspot.commit

        get :autocomplete, q: "author:höll", format: :json
        json = JSON.parse response.body

        expect(json.first["author"]).to eq 'Bert Hölldobler'
      end

      it "handles hyphens" do
        reference_factory author_name: 'M.S. Abdul-Rassoul'
        Sunspot.commit

        get :autocomplete, q: "author:abdul-ras", format: :json
        json = JSON.parse response.body

        expect(json.first["author"]).to eq 'M.S. Abdul-Rassoul'
      end
    end
  end
end
