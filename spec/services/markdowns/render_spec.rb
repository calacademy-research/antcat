# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::Render do
  describe "#call" do
    context 'with unsafe tags' do
      it "sanitizes them" do
        content = '<script>xss</script>'
        expect(described_class[content]).to eq "<p>xss</p>\n"
      end

      it "keeps `class` attributes, except in user content" do
        content = %(<div class="callout-danger">x</div>)

        expect(described_class[content]).to include 'class="callout-danger"'
        expect(described_class[content, user_content: true]).not_to include 'class='
      end

      it "does not remove <i> tags" do
        content = "<i>italics<i><i><script>xss</script></i>"
        expect(described_class[content]).to eq "<p><i>italics<i><i>xss</i></i></i></p>\n"
      end
    end

    context 'with links and images' do
      it "renders http, https, mailto, relative and anchor links" do
        expect(described_class['[a](https://example.com "T")']).
          to eq %(<p><a href="https://example.com" title="T">a</a></p>\n)
        expect(described_class['[a](http://example.com)']).to eq %(<p><a href="http://example.com">a</a></p>\n)
        expect(described_class['[a](mailto:x@example.com)']).to eq %(<p><a href="mailto:x@example.com">a</a></p>\n)
        expect(described_class['[a](/catalog/1)']).to eq %(<p><a href="/catalog/1">a</a></p>\n)
        expect(described_class['[a](#section)']).to eq %(<p><a href="#section">a</a></p>\n)
      end

      it "does not render links with unsafe schemes" do
        [
          '[a](javascript:alert`1`)',
          '[a](JavaScript:alert`1`)',
          '[a]( javascript:alert`1`)',
          '[a](data:text/html;base64,PHNjcmlwdD4=)',
          '[a](vbscript:msgbox)'
        ].each do |markdown|
          expect(described_class[markdown]).to eq "<p>a</p>\n"
        end
      end

      it "does not render reference-style links with unsafe schemes" do
        markdown = "[a][x]\n\n[x]: javascript:alert`1`"
        expect(described_class[markdown]).not_to include 'javascript'
      end

      it "does not double-escape ampersands in URLs" do
        expect(described_class['[a](https://example.com/?a=1&b=2)']).
          to eq %(<p><a href="https://example.com/?a=1&amp;b=2">a</a></p>\n)
      end

      it "renders images with safe URLs" do
        expect(described_class['![alt](https://example.com/a.png)']).
          to eq %(<p><img src="https://example.com/a.png" alt="alt"></p>\n)
      end

      it "does not render images with unsafe schemes" do
        expect(described_class['![alt](javascript:alert`1`)']).to eq "<p>alt</p>\n"
        expect(described_class['![alt](data:image/svg+xml;base64,PHN2Zz4=)']).to eq "<p>alt</p>\n"
      end

      it "autolinks URLs and email addresses" do
        expect(described_class['see https://example.com']).
          to eq %(<p>see <a href="https://example.com">https://example.com</a></p>\n)
        expect(described_class['x@example.com']).
          to eq %(<p><a href="mailto:x@example.com">x@example.com</a></p>\n)
      end
    end

    describe Markdowns::Render::AntCatMarkdown do
      describe '#link and #image' do
        let(:renderer) { described_class.new }

        it 'escapes attributes' do
          expect(renderer.link('/x?a=1&b=2', 'a"b', 'c')).to eq %(<a href="/x?a=1&amp;b=2" title="a&quot;b">c</a>)
          expect(renderer.link('/x?a=1&amp;b=2', nil, 'c')).to eq %(<a href="/x?a=1&amp;b=2">c</a>)
          expect(renderer.image('/x.png', nil, '"><script>')).to eq %(<img src="/x.png" alt="&quot;&gt;&lt;script&gt;">)
        end
      end

      describe '.safe_url?' do
        it 'allows only safe schemes and scheme-less URLs' do
          %w[http://a https://a mailto:a@b /a a/b ?q=1 #anchor].each do |url|
            expect(described_class.safe_url?(url)).to be(true), url
          end

          ['javascript:x', 'JAVASCRIPT:x', "java\tscript:x", 'data:x', 'vbscript:x', 'file:///etc', '', nil].each do |url|
            expect(described_class.safe_url?(url)).to be(false), url.inspect
          end
        end
      end
    end

    context 'with AntCat and catalog tags inside attribute values' do
      let(:user) { create :user }
      let(:taxon) { create :family }

      def expect_no_injected_elements rendered
        fragment = Nokogiri::HTML5.fragment(rendered)
        expect(fragment.css('img, [onerror]')).to be_empty
        expect(rendered).not_to include '<img'
      end

      it 'does not expand them inside attributes of raw HTML' do
        [
          %(<div title="@user#{user.id} <img src=x onerror=alert(1)>">ok</div>),
          %(<b title="{#{Taxt::TAX_TAG} #{taxon.id}} <img src=x onerror=alert(1)>">x</b>),
          %(<b title="%github1 <img src=x onerror=alert(1)>">x</b>),
          %(<b title="%wiki1 {missing <img src=x onerror=alert(1)>}">x</b>)
        ].each do |content|
          rendered = described_class[content]

          expect_no_injected_elements rendered
          expect(Nokogiri::HTML5.fragment(rendered).css('a')).to be_empty
        end
      end

      it 'does not expand them inside attributes built from markdown' do
        rendered = described_class[%([x](https://example.com/@user#{user.id} "{#{Taxt::TAX_TAG} #{taxon.id}} %github1"))]

        expect(rendered).to eq %(<p><a href="https://example.com/&#64;user#{user.id}" ) +
          %(title="&#123;#{Taxt::TAX_TAG} #{taxon.id}&#125; &#37;github1">x</a></p>\n)
      end

      it 'still expands them in text' do
        rendered = described_class[%(<b title="hint">@user#{user.id} {#{Taxt::TAX_TAG} #{taxon.id}} %github1</b>)]

        expect(rendered).to include %(<b title="hint">), %(href="/users/#{user.id}"), %(href="/catalog/#{taxon.id}"),
          "GitHub #1"
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
