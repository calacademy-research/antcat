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
      double = instance_double 'Markdowns::Render'
      allow(Markdowns::Render).to receive(:new).with(content, sanitize_content: false).and_return(double)
      allow(double).to receive(:call)

      helper.markdown_without_sanitation content

      expect(double).to have_received(:call)
    end
  end
end
