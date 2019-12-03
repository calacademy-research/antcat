require 'rails_helper'

describe ArticleReferenceDecorator do
  include TestLinksHelpers

  let(:author_name) { create :author_name, name: "Forel, A." }
  let!(:reference) do
    create :article_reference, :with_doi, author_names: [author_name], citation_year: '1874',
      title: "*Atta* <i>and such</i>", series_volume_issue: '(1)', pagination: '3'
  end

  describe "#plain_text" do
    specify { expect(reference.decorate.plain_text).to be_html_safe }

    specify do
      results = reference.decorate.plain_text
      expect(results).to be_html_safe
      expect(results).to eq "Forel, A. 1874. Atta and such. #{reference.journal.name} (1):3."
    end

    context 'with unsafe tags' do
      let!(:reference) do
        journal = create :journal, name: '<script>xss</script>'
        create :article_reference, journal: journal, pagination: '<script>xss</script>',
          series_volume_issue: '<script>xss</script>'
      end

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
        #{author_link(author_name)} 1874. <a href="/references/#{reference.id}"><i>Atta</i>
        <i>and such</i>.</a> #{reference.journal.name} (1):3.
      HTML
    end
  end

  describe "#expandable_reference" do
    before do
      allow(reference).to receive(:url).and_return 'example.com'
      allow(reference).to receive(:downloadable?).and_return true
    end

    specify do
      expect(reference.decorate.expandable_reference).to eq <<~HTML.squish
        <span data-tooltip="true" data-allow-html="true" data-tooltip-class="foundation-tooltip" tabindex="2"
          title="<a href=&quot;/authors/#{author_name.author.id}&quot;>#{author_name.name}</a> 1874.
            <a href=&quot;/references/#{reference.id}&quot;><i>Atta</i> <i>and such</i>.</a>
            #{reference.journal.name} (1):3.
            <a class=&quot;external-link&quot; href=&quot;https://doi.org/#{reference.doi}&quot;>#{reference.doi}</a>
            <a class=&quot;pdf-link&quot; href=&quot;example.com&quot;>PDF</a>">Forel, 1874</span>
      HTML
    end
  end
end
