# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::RenderWithoutWrappingP do
  describe "#call" do
    specify { expect(described_class['pizza']).to eq "pizza" }
    specify { expect(described_class['*pizza*']).to eq "<em>pizza</em>" }
    specify { expect(described_class[nil]).to eq nil }
    specify { expect(described_class['']).to eq '' }
    specify { expect(described_class['# pizza']).to eq "<h1>pizza</h1>\n" }

    it "keeps the paragraphs of content with several paragraphs" do
      rendered = described_class["pizza\n\npasta"]
      expect(rendered).to include "<p>pizza</p>"
      expect(rendered).to include "<p>pasta</p>"
    end
  end
end
