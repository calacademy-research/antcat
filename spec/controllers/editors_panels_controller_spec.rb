require "spec_helper"

describe EditorsPanelsController do
  render_views

  before { sign_in create :editor }

  describe 'GET index' do
    before { get :index }

    specify { expect(response).to render_template :index }
  end

  describe 'GET invite_users' do
    before { get :invite_users }

    specify { expect(response).to render_template :invite_users }
  end
end
