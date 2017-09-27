require 'spec_helper'

describe BookReferenceDecorator do
  let(:author_name) { create :author_name, name: "Forel, A." }

  describe "#formatted" do
    it "separates the publisher and the pagination with a comma" do
      publisher = create :publisher
      reference = create :book_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        publisher: publisher, pagination: "22 pp."
      expect(reference.decorate.formatted)
        .to eq 'Forel, A. 1874. Les fourmis de la Suisse. New York: Wiley, 22 pp.'
    end

    it "formats a citation_string correctly if the publisher doesn't have a place" do
      publisher = Publisher.create! name: "Wiley"
      reference = create :book_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        publisher: publisher,
        pagination: "22 pp."
      expect(reference.decorate.formatted)
        .to eq 'Forel, A. 1874. Les fourmis de la Suisse. Wiley, 22 pp.'
    end

    context "with unsafe characters" do
      let!(:author_names) { [create(:author_name, name: 'Ward, P. S.')] }

      it "escapes the citation in a book reference" do
        reference = create :book_reference,
          citation_year: '2010d',
          title: 'Ants are my life',
          author_names: author_names,
          publisher: create(:publisher, name: '<', place: create(:place, name: '>')),
          pagination: '>'
        expect(reference.decorate.formatted)
          .to eq 'Ward, P. S. 2010d. Ants are my life. &gt;: &lt;, &gt;.'
      end
    end
  end
end
