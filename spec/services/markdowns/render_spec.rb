# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::Render do
  describe "#call" do
    context 'with unsafe tags' do
      it "sanitizes them" do
        content = '<script>xss</script>'
        expect(described_class[content]).to eq "<p>xss</p>\n"
      end

      it "does not remove <i> tags" do
        content = "<i>italics<i><i><script>xss</script></i>"
        expect(described_class[content]).to eq "<p><i>italics<i><i>xss</i></i></i></p>\n"
      end
    end

    it "formats basic markdown" do
      markdown = <<~MARKDOWN
        ###Header
        * A list item

        *italics* **bold**
      MARKDOWN

      expect(described_class[markdown]).to eq <<~HTML
        <h3>Header</h3>

        <ul>
        <li>A list item</li>
        </ul>

        <p><em>italics</em> <strong>bold</strong></p>
      HTML
    end
  end
end
