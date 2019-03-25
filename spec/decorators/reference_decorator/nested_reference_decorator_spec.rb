require 'spec_helper'

describe NestedReferenceDecorator do
  include TestLinksHelpers

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
      citation_year: '1874', pages_in: 'Pp. 32-45 in'
  end

  describe "#plain_text" do
    specify { expect(reference.decorate.plain_text).to be_html_safe }

    specify do
      expect(reference.decorate.plain_text).
        to eq 'Forel, A. 1874. Atta and such. Pp. 32-45 in Mayr, E. 2010. Lasius and such. New York: Wiley, 32 pp.'
    end

    context 'with unsafe tags' do
      let!(:reference) do
        journal = create :journal, name: '<script>xss</script>'
        nesting_reference = create :article_reference, journal: journal, pagination: '<script>xss</script>',
          series_volume_issue: '<script>xss</script>'
        create :nested_reference, nesting_reference: nesting_reference, pages_in: '<script>xss</script>'
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
        #{author_link(author_name)} 1874. <a href="/references/#{reference.id}"><i>Atta</i> <i>and such</i>.</a>
        Pp. 32-45 in #{author_link(nestee_author_name)} 2010. <a href="/references/#{nestee_reference.id}"><i>Lasius</i>
        <i>and such</i>.</a> New York: Wiley, 32 pp.
      HTML
    end
  end

  describe '#pdf_link' do
    context 'when nested reference has a document' do
      let(:reference_document) { build(:reference_document) }
      let(:reference) { build :nested_reference }

      it 'links it' do
        expect(reference).to receive(:document).and_return(reference_document)
        expect(reference).to receive(:downloadable?).and_return(true)
        expect(reference_document).to receive(:url).and_return('reference.com')
        expect(reference.decorate.send(:pdf_link)).to eq '<a class="external-link" href="reference.com">PDF</a>'
      end
    end

    context 'when nested reference does not have a document' do
      context 'when parent reference has a document' do
        let(:parent_reference_document) { build(:reference_document) }
        let(:parent_reference) { build :book_reference }
        let(:reference) { build :nested_reference, nesting_reference: parent_reference }

        it "fallbacks to the parent's reference document" do
          expect(reference).to receive(:downloadable?).and_return(false)
          expect(parent_reference).to receive(:downloadable?).and_return(true)
          expect(parent_reference).to receive(:document).and_return(parent_reference_document)
          expect(parent_reference_document).to receive(:url).and_return('parent-reference.com')
          expect(reference.decorate.send(:pdf_link)).to eq '<a class="external-link" href="parent-reference.com">PDF</a>'
        end
      end
    end
  end
end
