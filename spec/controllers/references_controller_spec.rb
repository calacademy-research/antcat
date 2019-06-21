require 'spec_helper'

describe ReferencesController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(get(:new)).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create)).to redirect_to_signin_form }
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
    end

    context "when signed in as a helper editor" do
      before { sign_in create(:user, :helper) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

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
        create :reference, author_name: 'E.O. Wilson'
        create :reference, author_name: 'Bolton'
        Sunspot.commit
      end

      it "autocompletes" do
        get :autocomplete, params: { reference_q: "wilson", format: :json }

        expect(json_response.size).to eq 1
        expect(json_response.first["author"]).to eq 'E.O. Wilson'
      end
    end

    context "when there are no matches" do
      it "returns an empty response" do
        get :autocomplete, params: { reference_q: "willy", format: :json }
        expect(json_response.size).to eq 0
      end
    end

    describe "author queries not wrapped in quotes" do
      context "queries containing non-English characters" do
        before do
          create :reference, author_name: 'Bert Hölldobler'
          Sunspot.commit
        end

        it "autocompletes" do
          get :autocomplete, params: { reference_q: "author:höll", format: :json }

          expect(json_response.size).to eq 1
          expect(json_response.first["author"]).to eq 'Bert Hölldobler'
        end
      end

      context "queries containing hyphens" do
        before do
          create :reference, author_name: 'M.S. Abdul-Rassoul'
          Sunspot.commit
        end

        it "autocompletes" do
          get :autocomplete, params: { reference_q: "author:abdul-ras", format: :json }

          expect(json_response.size).to eq 1
          expect(json_response.first["author"]).to eq 'M.S. Abdul-Rassoul'
        end
      end
    end
  end
end
