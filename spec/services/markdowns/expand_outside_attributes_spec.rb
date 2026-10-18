# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::ExpandOutsideAttributes do
  describe '.call' do
    it 'expands text but not attribute values' do
      html = %(<b title="{x}">{x}</b>)
      result = described_class.call(html) { |masked| masked.gsub('{x}', '<a href="/y">y</a>') }

      expect(result).to eq %(<b title="{x}"><a href="/y">y</a></b>)
    end

    it 'escapes markup in attribute values when putting them back' do
      html = %(<b title="a <i> b &amp; &quot;c&quot;">x</b>)

      expect(described_class.call(html) { it }).to eq %(<b title="a &lt;i&gt; b &amp; &quot;c&quot;">x</b>)
    end

    it 'returns content without attributes as is' do
      html = "<i>italics</i> {x} a = b"
      expect(described_class.call(html) { it }).to eq html
    end

    it 'does not let content spoof placeholders' do
      html = %(<b title="secret">x</b> \u{E000}0\u{E001})
      expect(described_class.call(html) { it }).to eq %(<b title="secret">x</b> 0)
    end

    it 'keeps expansions that span elements' do
      html = %({missing <i title="t">Lasius</i>})
      result = described_class.call(html) { |masked| masked.gsub(/\{missing (.*?)\}/) { "<span>#{Regexp.last_match(1)}</span>" } }

      expect(result).to eq %(<span><i title="t">Lasius</i></span>)
    end
  end
end
