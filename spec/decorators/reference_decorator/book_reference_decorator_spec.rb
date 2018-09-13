require 'spec_helper'

describe BookReferenceDecorator do
  let(:author_name) { create :author_name, name: "Forel, A." }

  describe "#plain_text" do
    it "separates the publisher and the pagination with a comma" do
      reference = create :book_reference, author_names: [author_name],
        citation_year: "1874", title: "Les fourmis de la Suisse.", pagination: "22 pp."
      expect(reference.decorate.plain_text).
        to eq 'Forel, A. 1874. Les fourmis de la Suisse. San Francisco: Wiley, 22 pp.'
    end

    context "with unsafe characters" do
      it "escapes them" do
        publisher = create :publisher, name: '<', place_name: '>'
        reference = create :book_reference, publisher: publisher
        expect(reference.decorate.plain_text).to include ' &gt;: &lt;'
      end
    end
  end
end
