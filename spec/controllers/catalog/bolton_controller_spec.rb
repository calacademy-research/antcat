# frozen_string_literal: true

require 'rails_helper'

describe Catalog::BoltonController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:show, params: { id: 1 })).to redirect_to_signin_form }
    end
  end

  describe "GET show", as: :user do
    it "returns not found for unsupported ranks" do
      get :show, params: { id: create(:subfamily).id }
      expect(response).to have_http_status :not_found
    end
  end
end
