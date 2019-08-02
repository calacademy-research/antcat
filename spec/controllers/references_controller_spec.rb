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
end
