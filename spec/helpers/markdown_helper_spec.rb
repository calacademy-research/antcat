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

  describe "#markdown_without_sanitation" do
    let(:content) { "pizza" }

    it "calls `Markdowns::Render`" do
      expect(Markdowns::Render).to receive(:new).with(content, sanitize_content: false).and_call_original
      helper.markdown_without_sanitation content
    end
  end
end
