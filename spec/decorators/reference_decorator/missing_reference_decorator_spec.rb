require 'spec_helper'

describe MissingReferenceDecorator do
  let(:reference) do
    create :missing_reference, author_names: [], citation_year: '2010',
      citation: '*Atta* <i>and such</i>', title: 'Tapinoma'
  end

  describe "#plain_text" do
    specify { expect(reference.decorate.plain_text).to be_html_safe }

    specify do
      expect(reference.decorate.plain_text).to eq "2010. Tapinoma. Atta and such."
    end

    context 'with unsafe tags' do
      let(:reference) { create :missing_reference, citation: '<script>xss</script>' }

      it "sanitizes them" do
        results = reference.decorate.plain_text
        expect(results).to_not include '<script>xss</script>'
        expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
        expect(results).to include 'xss'
      end
    end
  end

  describe "#expanded_reference" do
    specify { expect(reference.decorate.expanded_reference).to be_html_safe }

    specify do
      expect(reference.decorate.expanded_reference).to eq <<~HTML.squish
        2010. <a href="/references/#{reference.id}">Tapinoma.</a> <i>Atta</i> <i>and such</i>.
      HTML
    end
  end

  describe "#format_document_links" do
    let(:reference) { build_stubbed :missing_reference, citation: "citation" }

    specify { expect(reference.decorate.format_document_links).to be_nil }
  end
end
