require 'spec_helper'

describe UnknownReferenceDecorator do
  describe "#plain_text" do
    let(:author_name) { create :author_name, name: "Forel, A." }

    it "formats unknown references" do
      reference = create :unknown_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        citation: 'New York'
      expect(reference.decorate.plain_text).to eq 'Forel, A. 1874. Les fourmis de la Suisse. New York.'
    end

    it "returns an html_safe string" do
      reference = create :unknown_reference
      expect(reference.decorate.plain_text).to be_html_safe
    end

    it "italicizes the citation" do
      reference = create :unknown_reference, citation: '*Ants* <i>et al.</i>'
      expect(reference.decorate.plain_text).to include '<i>Ants</i> <i>et al.</i>'
    end

    context "with unsafe characters" do
      let!(:author_names) { [create(:author_name, name: 'Ward, P. S.')] }

      it "escapes them" do
        reference = create :unknown_reference, citation: '<span>Tapinoma</span>'
        expect(reference.decorate.plain_text).to include "&lt;span&gt;Tapinoma&lt;/span&gt;"
      end
    end
  end
end
