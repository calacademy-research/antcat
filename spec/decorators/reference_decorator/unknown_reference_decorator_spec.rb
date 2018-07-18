require 'spec_helper'

describe UnknownReferenceDecorator do
  let(:author_name) { create :author_name, name: "Forel, A." }

  describe "#formatted" do
    it "formats unknown references" do
      reference = create :unknown_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse.",
        citation: 'New York'
      expect(reference.decorate.formatted).to eq 'Forel, A. 1874. Les fourmis de la Suisse. New York.'
    end

    it "returns an html_safe string" do
      reference = create :unknown_reference,
        citation_year: '2010d',
        author_names: [],
        citation: '*Ants*',
        title: '*Tapinoma*'
      expect(reference.decorate.formatted).to be_html_safe
    end

    describe "italicizing title and citation" do
      it "italicizes the title and citation" do
        reference = create :unknown_reference,
          citation_year: '2010d',
          author_names: [],
          citation: '*Ants*',
          title: '*Tapinoma*'
        expect(reference.decorate.formatted).to eq "2010d. <i>Tapinoma</i>. <i>Ants</i>."
      end

      it "escapes other HTML in title and citation" do
        reference = create :unknown_reference,
          citation_year: '2010d',
          author_names: [],
          citation: '*Ants*',
          title: '<span>Tapinoma</span>'
        expect(reference.decorate.formatted).
          to eq "2010d. &lt;span&gt;Tapinoma&lt;/span&gt;. <i>Ants</i>."
      end

      it "doesn't escape et al. in citation" do
        reference = create :unknown_reference,
          author_names: [],
          citation_year: '2010',
          citation: 'Ants <i>et al.</i>',
          title: 'Tapinoma'
        expect(reference.decorate.formatted).to eq "2010. Tapinoma. Ants <i>et al.</i>."
      end
    end

    context "with unsafe characters" do
      let!(:author_names) { [create(:author_name, name: 'Ward, P. S.')] }

      it "escapes the citation in an unknown reference" do
        reference = create :unknown_reference,
          title: 'Ants are my life',
          citation_year: '2010d',
          author_names: author_names,
          citation: '>'
        expect(reference.decorate.formatted).to eq 'Ward, P. S. 2010d. Ants are my life. &gt;.'
      end
    end
  end
end
