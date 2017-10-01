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
        expect(reference.decorate.formatted)
          .to eq 'Ward, P. S. 2010d. Ants are my life. &gt; Ward, P. S. 2010d. Ants are my life. New York.'
      end
    end
  end
end
