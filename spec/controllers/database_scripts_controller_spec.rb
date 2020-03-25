require 'rails_helper'

describe DatabaseScriptsController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:index)).to redirect_to_signin_form }
      specify { expect(get(:show, params: { id: 1 })).to redirect_to_signin_form }
    end
  end

  describe "GET index", as: :user do
    specify { expect(get(:index)).to render_template :index }
  end

  describe "GET show", as: :user do
    specify { expect(get(:show, params: { id: 'orphaned_protonyms' })).to render_template :show }
  end
end
