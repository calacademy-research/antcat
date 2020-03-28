# frozen_string_literal: true

require 'rails_helper'

describe References::Formatted::PlainText do
  subject(:formatter) { described_class.new(reference) }

  describe '#call' do
    context 'when reference is an `ArticleReference`' do
      let(:author_name) { create :author_name, name: "Forel, A." }
      let(:reference) do
        create :article_reference, :with_doi, author_names: [author_name], citation_year: '1874',
          title: "*Atta* <i>and such</i>", series_volume_issue: '(1)', pagination: '3'
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).to eq "Forel, A. 1874. Atta and such. #{reference.journal.name} (1):3."
      end

      context 'with unsafe tags' do
        let(:reference) do
          journal = create :journal, name: '<script>xss</script>'
          create :article_reference, journal: journal, pagination: '<script>xss</script>',
            series_volume_issue: '<script>xss</script>'
        end

        it "sanitizes them" do
          results = formatter.call
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    context 'when reference is a `BookReference`' do
      let(:author_name) { create :author_name, name: "Forel, A." }
      let(:reference) do
        create :book_reference, author_names: [author_name],
          citation_year: "1874", title: '*Ants* <i>and such</i>', pagination: "22 pp.",
          publisher: create(:publisher, name: 'Wiley', place: 'San Francisco')
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).to eq 'Forel, A. 1874. Ants and such. San Francisco: Wiley, 22 pp.'
      end

      context 'with unsafe tags' do
        let(:reference) do
          publisher = create :publisher, name: '<script>xss</script>', place: '<script>xss</script>'
          create :book_reference, publisher: publisher, pagination: '<script>xss</script>'
        end

        it "sanitizes them" do
          results = formatter.call
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    context 'when reference is a `NestedReference`' do
      let(:nestee_author_name) { create :author_name, name: "Mayr, E." }
      let(:author_name) { create :author_name, name: "Forel, A." }
      let(:nestee_reference) do
        create :book_reference, author_names: [nestee_author_name],
          citation_year: '2010', title: '*Lasius* <i>and such</i>', pagination: '32 pp.',
          publisher: create(:publisher, name: 'Wiley', place: 'New York')
      end
      let(:reference) do
        create :nested_reference, nesting_reference: nestee_reference,
          author_names: [author_name], title: '*Atta* <i>and such</i>',
          citation_year: '1874', pagination: 'Pp. 32-45 in'
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).
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
          results = formatter.call
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    context 'when reference is a `MissingReference`' do
      let(:reference) do
        create :missing_reference, citation_year: '2010',
          citation: '*Atta* <i>and such</i>', title: 'Tapinoma'
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).to eq " 2010. Tapinoma. Atta and such."
      end

      context 'with unsafe tags' do
        let(:reference) { create :missing_reference, citation: '<script>xss</script>' }

        it "sanitizes them" do
          results = formatter.call
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    context 'when reference is a `UnknownReference`' do
      let(:author_name) { create :author_name, name: "Forel, A." }
      let(:reference) do
        create :unknown_reference, author_names: [author_name], citation_year: "1874",
          title: "Les fourmis de la Suisse.", citation: '*Ants* <i>and such</i>'
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).to eq 'Forel, A. 1874. Les fourmis de la Suisse. Ants and such.'
      end

      context 'with unsafe tags' do
        let(:reference) { create :unknown_reference, citation: 'Atta <script>xss</script>' }

        it "sanitizes them" do
          results = formatter.call
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'Atta xss'
        end
      end
    end
  end
end
