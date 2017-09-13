require "spec_helper"

describe MarkdownHelper do
  let(:string) { "should be delegated" }

  describe "#markdown" do
    it "formats markdown (delegates)" do
      expect(AntcatMarkdown).to receive(:render).with string
      helper.markdown string
    end
  end
end
