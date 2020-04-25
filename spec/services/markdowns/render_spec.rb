# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::Render do
  include TestLinksHelpers

  describe "#call" do
    it "formats some basic markdown" do
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
