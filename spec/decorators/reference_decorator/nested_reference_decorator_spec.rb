require 'spec_helper'

describe NestedReferenceDecorator do
  let(:author_name) { create :author_name, name: "Forel, A." }

  describe "#formatted" do
    it "formats nested references" do
      reference = create :book_reference,
        author_names: [create(:author_name, name: 'Mayr, E.')],
        citation_year: '2010',
        title: 'Ants I have known',
        publisher: create(:publisher, name: 'Wiley', place: create(:place, name: 'New York')),
        pagination: '32 pp.'
      nested_reference = create :nested_reference, nesting_reference: reference,
        author_names: [author_name], title: 'Les fourmis de la Suisse',
        citation_year: '1874', pages_in: 'Pp. 32-45 in'
      expect(nested_reference.decorate.formatted).to eq(
        'Forel, A. 1874. Les fourmis de la Suisse. Pp. 32-45 in Mayr, E. 2010. Ants I have known. New York: Wiley, 32 pp.'
      )
    end

    context "with unsafe characters" do
      let!(:author_names) { [create(:author_name, name: 'Ward, P. S.')] }

      it "escapes the citation in a nested reference" do
        nested_reference = create :unknown_reference,
          title: "Ants are my life",
          citation_year: '2010d',
          author_names: author_names
        reference = create :nested_reference,
          title: "Ants are my life",
          citation_year: '2010d',
          author_names: author_names,
          pages_in: '>',
          nesting_reference: nested_reference
        expect(reference.decorate.formatted).
          to eq 'Ward, P. S. 2010d. Ants are my life. &gt; Ward, P. S. 2010d. Ants are my life. New York.'
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
        expect(reference.decorate.send(:pdf_link)).to eq '<a href="reference.com">PDF</a>'
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
          expect(reference.decorate.send(:pdf_link)).to eq '<a href="parent-reference.com">PDF</a>'
        end
      end
    end
  end
end
