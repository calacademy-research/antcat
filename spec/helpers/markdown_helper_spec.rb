require "spec_helper"

describe MarkdownHelper do
  let(:string) { "should be delegated" }

  describe "#markdown" do
    it "formats markdown (delegates)" do
      expect(Markdowns::Render).to receive(:new).with(string).and_call_original
      helper.markdown string
    end
  end
end
