require 'spec_helper'

describe NestedReferenceDecorator do
  describe "#plain_text" do
    let(:author_name) { create :author_name, name: "Forel, A." }

    it "formats nested references" do
      reference = create :book_reference, author_names: [create(:author_name, name: 'Mayr, E.')],
        citation_year: '2010', title: 'My Ants', pagination: '32 pp.',
        publisher: create(:publisher, name: 'Wiley', place_name: 'New York')
      nested_reference = create :nested_reference, nesting_reference: reference,
        author_names: [author_name], title: 'Les fourmis',
        citation_year: '1874', pages_in: 'Pp. 32-45 in'

      expect(nested_reference.decorate.plain_text).
        to eq 'Forel, A. 1874. Les fourmis. Pp. 32-45 in Mayr, E. 2010. My Ants. New York: Wiley, 32 pp.'
    end

    context "with unsafe characters" do
      it "escapes them" do
        reference = create :nested_reference, pages_in: 'Pp. >'
        expect(reference.decorate.plain_text).to include 'Pp. &gt;'
      end
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
