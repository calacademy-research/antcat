# frozen_string_literal: true

require 'rails_helper'

describe EditorsPanels::BoltonKeysToRefTagsController do
  describe "GET show", as: :visitor do
    specify { expect(get(:show)).to render_template :show }
  end

  describe "POST create", as: :visitor do
    let(:bolton_content) { "content" }

    it "calls `Markdowns::BoltonKeysToRefTags`" do
      expect(Markdowns::BoltonKeysToRefTags).to receive(:new).with(bolton_content).and_call_original
      post :create, params: { bolton_content: bolton_content }
    end
  end
end
