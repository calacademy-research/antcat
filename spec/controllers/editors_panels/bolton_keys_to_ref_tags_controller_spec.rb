require 'rails_helper'

describe EditorsPanels::BoltonKeysToRefTagsController do
  describe "GET show" do
    specify { expect(get(:show)).to render_template :show }
  end

  describe "POST create" do
    let(:bolton_content) { "zootaxa" }

    it "calls `Markdowns::BoltonKeysToRefTags`" do
      expect(Markdowns::BoltonKeysToRefTags).to receive(:new).with(bolton_content).and_call_original
      post :create, params: { bolton_content: bolton_content }
    end
  end
end
