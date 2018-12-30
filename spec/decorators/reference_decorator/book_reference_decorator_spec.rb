require 'spec_helper'

describe BookReferenceDecorator do
  let(:author_name) { create :author_name, name: "Forel, A." }
  let(:reference) do
    create :book_reference, author_names: [author_name],
      citation_year: "1874", title: '*Ants* <i>and such</i>', pagination: "22 pp."
  end

  describe "#plain_text" do
    specify { expect(reference.decorate.plain_text).to be_html_safe }

    specify do
      expect(reference.decorate.plain_text).
        to eq 'Forel, A. 1874. Ants and such. San Francisco: Wiley, 22 pp.'
    end

    context "with unsafe characters" do
      it "escapes them" do
        publisher = create :publisher, name: '<', place_name: '>'
        reference = create :book_reference, publisher: publisher
        expect(reference.decorate.plain_text).to include ' &gt;: &lt;'
      end
    end
  end

  describe "#expanded_reference" do
    specify { expect(reference.decorate.expanded_reference).to be_html_safe }

    specify do
      expect(reference.decorate.expanded_reference).to eq <<~HTML.squish
        Forel, A. 1874. <i>Ants</i> <i>and such</i>. San Francisco: Wiley, 22 pp.
      HTML
    end
  end
end
