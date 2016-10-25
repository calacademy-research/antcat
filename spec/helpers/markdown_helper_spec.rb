require "spec_helper"

describe MarkdownHelper do
  describe "#markdown" do
    it "formats markdown (delegates)" do
      markdown = "should be delegated"
      expect(AntcatMarkdown).to receive(:render).with markdown
      helper.markdown markdown
    end

    it "strips markdown (delegates)" do
      markdown = "should be delegated"
      expect(AntcatMarkdown).to receive(:strip).with markdown
      helper.strip_markdown markdown
    end
  end
end
