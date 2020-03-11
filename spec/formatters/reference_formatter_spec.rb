require 'rails_helper'

describe ReferenceFormatter do
  include TestLinksHelpers

  subject(:formatter) { described_class.new(reference) }

  context 'when reference is an `ArticleReference`' do
    let(:author_name) { create :author_name, name: "Forel, A." }
    let(:reference) do
      create :article_reference, :with_doi, author_names: [author_name], citation_year: '1874',
        title: "*Atta* <i>and such</i>", series_volume_issue: '(1)', pagination: '3'
    end

    describe "#plain_text" do
      specify { expect(formatter.plain_text).to be_html_safe }

      specify do
        results = formatter.plain_text
        expect(results).to be_html_safe
        expect(results).to eq "Forel, A. 1874. Atta and such. #{reference.journal.name} (1):3."
      end

      context 'with unsafe tags' do
        let(:reference) do
          journal = create :journal, name: '<script>xss</script>'
          create :article_reference, journal: journal, pagination: '<script>xss</script>',
            series_volume_issue: '<script>xss</script>'
        end

        it "sanitizes them" do
          results = formatter.plain_text
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    describe "#expanded_reference" do
      specify { expect(formatter.expanded_reference).to be_html_safe }

      specify do
        expect(formatter.expanded_reference).to eq <<~HTML.squish
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
        expect(formatter.expandable_reference).to eq <<~HTML.squish
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

  context 'when reference is a `BookReference`' do
    let(:author_name) { create :author_name, name: "Forel, A." }
    let(:reference) do
      create :book_reference, author_names: [author_name],
        citation_year: "1874", title: '*Ants* <i>and such</i>', pagination: "22 pp.",
        publisher: create(:publisher, name: 'Wiley', place_name: 'San Francisco')
    end

    describe "#plain_text" do
      specify { expect(formatter.plain_text).to be_html_safe }

      specify do
        expect(formatter.plain_text).
          to eq 'Forel, A. 1874. Ants and such. San Francisco: Wiley, 22 pp.'
      end

      context 'with unsafe tags' do
        let(:reference) do
          publisher = create :publisher, name: '<script>xss</script>', place_name: '<script>xss</script>'
          create :book_reference, publisher: publisher, pagination: '<script>xss</script>'
        end

        it "sanitizes them" do
          results = formatter.plain_text
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    describe "#expanded_reference" do
      specify { expect(formatter.expanded_reference).to be_html_safe }

      specify do
        expect(formatter.expanded_reference).to eq <<~HTML.squish
          #{author_link(author_name)} 1874. <a href="/references/#{reference.id}"><i>Ants</i>
          <i>and such</i>.</a> San Francisco: Wiley, 22 pp.
        HTML
      end
    end
  end

  context 'when reference is a `NestedReference`' do
    let(:nestee_author_name) { create :author_name, name: "Mayr, E." }
    let(:author_name) { create :author_name, name: "Forel, A." }

    let(:nestee_reference) do
      create :book_reference, author_names: [nestee_author_name],
        citation_year: '2010', title: '*Lasius* <i>and such</i>', pagination: '32 pp.',
        publisher: create(:publisher, name: 'Wiley', place_name: 'New York')
    end
    let(:reference) do
      create :nested_reference, nesting_reference: nestee_reference,
        author_names: [author_name], title: '*Atta* <i>and such</i>',
        citation_year: '1874', pagination: 'Pp. 32-45 in'
    end

    describe "#plain_text" do
      specify { expect(formatter.plain_text).to be_html_safe }

      specify do
        expect(formatter.plain_text).
          to eq 'Forel, A. 1874. Atta and such. Pp. 32-45 in Mayr, E. 2010. Lasius and such. New York: Wiley, 32 pp.'
      end

      context 'with unsafe tags' do
        let(:reference) do
          journal = create :journal, name: '<script>xss</script>'
          nesting_reference = create :article_reference, journal: journal, pagination: '<script>xss</script>',
            series_volume_issue: '<script>xss</script>'
          create :nested_reference, nesting_reference: nesting_reference, pagination: '<script>xss</script>'
        end

        it "sanitizes them" do
          results = formatter.plain_text
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    describe "#expanded_reference" do
      specify { expect(formatter.expanded_reference).to be_html_safe }

      specify do
        expect(formatter.expanded_reference).to eq <<~HTML.squish
          #{author_link(author_name)} 1874. <a href="/references/#{reference.id}"><i>Atta</i> <i>and such</i>.</a>
          Pp. 32-45 in #{author_link(nestee_author_name)} 2010. <a href="/references/#{nestee_reference.id}"><i>Lasius</i>
          <i>and such</i>.</a> New York: Wiley, 32 pp.
        HTML
      end
    end
  end

  context 'when reference is a `MissingReference`' do
    let(:reference) do
      create :missing_reference, author_names: [], citation_year: '2010',
        citation: '*Atta* <i>and such</i>', title: 'Tapinoma'
    end

    describe "#plain_text" do
      specify { expect(formatter.plain_text).to be_html_safe }

      specify do
        expect(formatter.plain_text).to eq " 2010. Tapinoma. Atta and such."
      end

      context 'with unsafe tags' do
        let(:reference) { create :missing_reference, citation: '<script>xss</script>' }

        it "sanitizes them" do
          results = formatter.plain_text
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    describe "#expanded_reference" do
      specify { expect(formatter.expanded_reference).to be_html_safe }

      specify do
        expect(formatter.expanded_reference.strip).to eq <<~HTML.squish
          2010. <a href="/references/#{reference.id}">Tapinoma.</a> <i>Atta</i> <i>and such</i>.
        HTML
      end
    end
  end

  context 'when reference is a `UnknownReference`' do
    let(:author_name) { create :author_name, name: "Forel, A." }
    let(:reference) do
      create :unknown_reference, author_names: [author_name], citation_year: "1874",
        title: "Les fourmis de la Suisse.", citation: '*Ants* <i>and such</i>'
    end

    describe "#plain_text" do
      specify { expect(formatter.plain_text).to be_html_safe }

      specify do
        expect(formatter.plain_text).to eq 'Forel, A. 1874. Les fourmis de la Suisse. Ants and such.'
      end

      context 'with unsafe tags' do
        let(:reference) { create :unknown_reference, citation: 'Atta <script>xss</script>' }

        it "sanitizes them" do
          results = formatter.plain_text
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'Atta xss'
        end
      end
    end

    describe "#expanded_reference" do
      specify { expect(formatter.expanded_reference).to be_html_safe }

      specify do
        expect(formatter.expanded_reference).to eq <<~HTML.squish
          #{author_link(author_name)} 1874. <a href="/references/#{reference.id}">Les fourmis de la Suisse.</a>
          <i>Ants</i> <i>and such</i>.
        HTML
      end
    end
  end

  context 'when reference is online early' do
    let(:reference) { create :article_reference, online_early: true }

    specify { expect(formatter.expandable_reference).to include ' [online early]' }
    specify { expect(formatter.expanded_reference).to include ' [online early]' }
  end
end
