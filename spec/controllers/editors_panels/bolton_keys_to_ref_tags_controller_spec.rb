# frozen_string_literal: true

require 'rails_helper'

describe EditorsPanels::BoltonKeysToRefTagsController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:show)).to redirect_to_signin_form }
      specify { expect(post(:create, params: { bolton_content: "x" })).to redirect_to_signin_form }
    end

    context "when signed in as a user", as: :user do
      specify { expect(get(:show)).to have_http_status :forbidden }
      specify { expect(post(:create, params: { bolton_content: "x" })).to have_http_status :forbidden }
    end
  end

  describe "GET show", as: :helper do
    specify { expect(get(:show)).to render_template :show }
  end

  describe "POST create", as: :helper do
    let(:bolton_content) { "content" }

    it "calls `Markdowns::BoltonKeysToRefTags`" do
      expect(Markdowns::BoltonKeysToRefTags).to receive(:new).with(bolton_content).and_call_original
      post :create, params: { bolton_content: bolton_content }
    end

    context "when the content is too large" do
      let(:bolton_content) { "a" * (Markdowns::BoltonKeysToRefTags::MAX_CONTENT_LENGTH + 1) }

      it "does not convert it" do
        expect(Reference).not_to receive(:where)

        post :create, params: { bolton_content: bolton_content }, format: :json

        expect(response).to have_http_status :content_too_large
        expect(json_response).to eq("error" => described_class::TOO_LARGE_MESSAGE)
      end

      it "shows a message on the page" do
        post :create, params: { bolton_content: bolton_content }

        expect(response).to have_http_status :content_too_large
        expect(response.body).to include "Too much content to convert at once"
      end
    end

    context "when there are too many Bolton keys" do
      let(:bolton_content) { "a:" * (Markdowns::BoltonKeysToRefTags::MAX_BOLTON_KEYS + 1) }

      specify do
        post :create, params: { bolton_content: bolton_content }, format: :json
        expect(response).to have_http_status :content_too_large
      end
    end
  end
end
