# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::RenderDocument do
  describe "#call" do
    def fragment_of rendered
      Nokogiri::HTML5.fragment(rendered)
    end

    context 'with a document as an .md file has it' do
      it "renders quotations, with Markdown inside them" do
        rendered = described_class["Text.\n\n> quoted *text* and [a link](/catalog/1)\n> second line\n\nMore text."]
        quotations = fragment_of(rendered).css('blockquote')

        expect(quotations.size).to eq 1
        expect(quotations.first.text).to include "quoted text and a link", "second line"
        expect(quotations.first.css('em').map(&:text)).to eq ["text"]
        expect(quotations.first.css('a').pluck('href')).to eq ["/catalog/1"]
        expect(quotations.first.text).not_to include "More text"
      end

      it "renders a quotation without a space after the mark" do
        expect(fragment_of(described_class[">quoted"]).css('blockquote').map { |quote| quote.text.strip }).to eq ["quoted"]
      end

      it "renders headings, tables and HTML italics" do
        rendered = described_class["## Etymological notes\n\n<i>Lasius</i>\n\n| a | b |\n|---|---|\n| 1 | 2 |"]
        fragment = fragment_of(rendered)

        expect(fragment.css('h2').map(&:text)).to eq ["Etymological notes"]
        expect(fragment.css('i').map(&:text)).to eq ["Lasius"]
        expect(fragment.css('table th').map(&:text)).to eq %w[a b]
        expect(fragment.css('table td').map(&:text)).to eq %w[1 2]
      end

      it "escapes code blocks once" do
        expect(described_class["```\na < b && c\n```"]).to include "<pre><code>a &lt; b &amp;&amp; c\n</code></pre>"
      end

      it "does not render a quotation mark inside a code block as a quotation" do
        expect(fragment_of(described_class["```\n> not quoted\n```"]).css('blockquote')).to be_empty
      end
    end

    context 'with unsafe content' do
      def expect_nothing_live rendered
        fragment = fragment_of(rendered)

        expect(fragment.css('script, iframe, style, [onerror], [onclick], [style]')).to be_empty
        expect(fragment.css('a').map { |link| link['href'].to_s }.grep(/javascript/i)).to be_empty
      end

      it "sanitizes the HTML that Markdown produced" do
        [
          '<script>alert(1)</script>',
          '<a href="javascript:alert(1)">x</a>',
          '[x](javascript:alert`1`)',
          '<b onclick="alert(1)">x</b>',
          '<iframe src="https://example.com"></iframe>',
          "> <script>alert(1)</script>",
          "> <b onclick=\"alert(1)\">x</b>"
        ].each do |content|
          expect_nothing_live described_class[content]
        end
      end

      it "sanitizes markup that spans lines around a quotation mark" do
        [
          %(<span title="a\n> <img src=x onerror=alert(1)>">t</span>),
          %(<b title="a\n><img src=x onerror=alert(1)>\n">t</b>),
          %(<b\n> onclick="alert(1)">t</b>),
          %(text <b title='\n> "><img src=x onerror=alert(1)>'>t</b>)
        ].each do |content|
          expect_nothing_live described_class[content]
        end
      end

      it "does not keep `class` attributes" do
        expect(described_class[%(<div class="callout-danger">x</div>)]).not_to include 'class='
      end

      it "does not turn the info string of fenced code blocks into a `class` attribute" do
        rendered = described_class["```{.callout-danger .fixed}\ncode <b>\n```"]

        expect(rendered).not_to include 'class='
        expect(rendered).to include "<pre><code>"
      end
    end

    context 'with AntCat and catalog tags' do
      let(:user) { create :user }
      let(:taxon) { create :family }

      it 'expands them in the text' do
        rendered = described_class["> {#{Taxt::TAX_TAG} #{taxon.id}}"]

        expect(fragment_of(rendered).css('blockquote a').pluck('href')).to eq ["/catalog/#{taxon.id}"]
      end

      it 'does not expand them inside attribute values' do
        [
          %(<div title="@user#{user.id} <img src=x onerror=alert(1)>">ok</div>),
          %(<b title="{#{Taxt::TAX_TAG} #{taxon.id}} <img src=x onerror=alert(1)>">x</b>),
          %([x](https://example.com/ "{#{Taxt::TAX_TAG} #{taxon.id}} %github1"))
        ].each do |content|
          fragment = fragment_of(described_class[content])

          expect(fragment.css('img, [onerror]')).to be_empty
          expect(fragment.css('a').pluck('href') - ["https://example.com/"]).to be_empty
        end
      end
    end
  end
end
