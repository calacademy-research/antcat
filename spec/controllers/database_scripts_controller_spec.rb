# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScriptsController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:index)).to redirect_to_signin_form }
      specify { expect(get(:show, params: { id: 1 })).to redirect_to_signin_form }
    end

    context "when signed in as a user", as: :user do
      specify { expect(get(:index)).to have_http_status :forbidden }
      specify { expect(get(:show, params: { id: 'orphaned_protonyms' })).to have_http_status :forbidden }
    end
  end

  describe "GET index", as: :helper do
    specify { expect(get(:index)).to render_template :index }
  end

  describe "GET show", as: :helper do
    specify { expect(get(:show, params: { id: 'orphaned_protonyms' })).to render_template :show }
  end
end
