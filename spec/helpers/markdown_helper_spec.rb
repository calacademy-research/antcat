# frozen_string_literal: true

require 'rails_helper'

describe MarkdownHelper do
  describe "#markdown" do
    let(:content) { "pizza" }

    it "calls `Markdowns::Render`" do
      expect(Markdowns::Render).to receive(:new).with(content).and_call_original
      helper.markdown content
    end
  end

  describe "#user_markdown" do
    it "renders without `class` attributes" do
      expect(helper.user_markdown(%(<span class="callout-danger" title="t">x</span>))).
        to eq %(<p><span title="t">x</span></p>\n)
    end
  end
end
