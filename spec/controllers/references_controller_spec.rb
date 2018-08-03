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

  describe "GET autocomplete", :search do
    context "when there are matches" do
      before do
        reference_factory author_name: 'E.O. Wilson'
        reference_factory author_name: 'Bolton'
        Sunspot.commit
      end

      it "autocompletes" do
        get :autocomplete, params: { q: "wilson", format: :json }

        json = JSON.parse response.body
        expect(json.size).to eq 1
        expect(json.first["author"]).to eq 'E.O. Wilson'
      end
    end

    context "when there are no matches" do
      it "returns an empty response" do
        get :autocomplete, params: { q: "willy", format: :json }

        json = JSON.parse response.body
        expect(json.size).to eq 0
      end
    end

    describe "author queries not wrapped in quotes" do
      context "queries containing non-English characters" do
        before do
          reference_factory author_name: 'Bert Hölldobler'
          Sunspot.commit
        end

        it "autocompletes" do
          get :autocomplete, params: { q: "author:höll", format: :json }

          json = JSON.parse response.body
          expect(json.size).to eq 1
          expect(json.first["author"]).to eq 'Bert Hölldobler'
        end
      end

      context "queries containing hyphens" do
        before do
          reference_factory author_name: 'M.S. Abdul-Rassoul'
          Sunspot.commit
        end

        it "autocompletes" do
          get :autocomplete, params: { q: "author:abdul-ras", format: :json }

          json = JSON.parse response.body
          expect(json.size).to eq 1
          expect(json.first["author"]).to eq 'M.S. Abdul-Rassoul'
        end
      end
    end
  end
end
