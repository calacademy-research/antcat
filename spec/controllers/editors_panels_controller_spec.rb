require "spec_helper"

describe EditorsPanelsController do
  render_views

  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(get(:index)).to redirect_to_signin_form }
    end
  end

  describe 'GET index' do
    before do
      sign_in create(:user, :editor)
      get :index
    end

    specify { expect(response).to render_template :index }
  end

  describe 'GET invite_users' do
    before do
      sign_in create(:user, :editor)
      get :invite_users
    end

    specify { expect(response).to render_template :invite_users }
  end
end
