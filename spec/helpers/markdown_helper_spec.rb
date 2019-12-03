require 'rails_helper'

describe MarkdownHelper do
  describe "#markdown" do
    let(:content) { "pizza" }

    it "calls `Markdowns::Render`" do
      expect(Markdowns::Render).to receive(:new).with(content, sanitize_content: true).and_call_original
      helper.markdown content
    end
  end
end
