# frozen_string_literal: true

require 'rails_helper'

describe MarkdownController do
  describe "POST preview", as: :visitor do
    let(:text) { "markdown" }

    it "calls `Markdowns::Render`" do
      expect(Markdowns::Render).to receive(:new).with(text).and_call_original
      post :preview, params: { text: text }
    end
  end
end
