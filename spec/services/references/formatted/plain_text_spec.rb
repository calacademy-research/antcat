# frozen_string_literal: true

require 'rails_helper'

describe References::Formatted::PlainText do
  subject(:formatter) { described_class.new(reference) }

  describe '#call' do
    context 'when reference is an `ArticleReference`' do
      let(:reference) do
        create :article_reference, :with_doi, author_string: "Forel, A.",
          title: "*Italics* <i>and such</i>", series_volume_issue: '(1)', pagination: '3'
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).to eq "Forel, A. #{reference.year}. Italics and such. #{reference.journal.name} (1):3."
      end

      context 'with unsafe tags' do
        let(:reference) do
          journal = create :journal, name: '<script>xss</script>'
          create :article_reference, journal: journal, pagination: '<script>xss</script>',
            series_volume_issue: '<script>xss</script>'
        end

        it "sanitizes them" do
          results = formatter.call
          expect(results).not_to include '<script>xss</script>'
          expect(results).not_to include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    context 'when reference is a `BookReference`' do
      let(:reference) do
        create :book_reference, author_string: "Forel, A.",
          title: '*Ants* <i>and such</i>', pagination: "22 pp.",
          publisher: create(:publisher, name: 'Wiley', place: 'San Francisco')
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).to eq "Forel, A. #{reference.year}. Ants and such. San Francisco: Wiley, 22 pp."
      end

      context 'with unsafe tags' do
        let(:reference) do
          publisher = create :publisher, name: '<script>xss</script>', place: '<script>xss</script>'
          create :book_reference, publisher: publisher, pagination: '<script>xss</script>'
        end

        it "sanitizes them" do
          results = formatter.call
          expect(results).not_to include '<script>xss</script>'
          expect(results).not_to include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end

    context 'when reference is a `NestedReference`' do
      let(:nesting_reference) do
        create :book_reference, author_string: "Mayr, E.",
          title: '*Lasius* <i>and such</i>', pagination: '32 pp.',
          publisher: create(:publisher, name: 'Wiley', place: 'New York')
      end
      let(:reference) do
        create :nested_reference, nesting_reference: nesting_reference,
          author_string: "Forel, A.", title: '*Italics* <i>and such</i>',
          pagination: 'Pp. 32-45 in:'
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).
          to eq "Forel, A. #{reference.year}. Italics and such. Pp. 32-45 in: Mayr, E. #{nesting_reference.year}. Lasius and such. New York: Wiley, 32 pp."
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
          expect(results).not_to include '<script>xss</script>'
          expect(results).not_to include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end
  end
end
