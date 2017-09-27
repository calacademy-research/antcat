require 'spec_helper'

describe ArticleReferenceDecorator do
  let(:journal) { create :journal, name: "Neue Denkschriften" }
  let(:author_name) { create :author_name, name: "Forel, A." }

  describe "#formatted" do
    it "formats the reference" do
      reference = create :article_reference,
        author_names: [author_name],
        citation_year: "1874",
        title: "Les fourmis de la Suisse",
        journal: journal,
        series_volume_issue: "26",
        pagination: "1-452"
      results = reference.decorate.formatted
      expect(results).to be_html_safe
      expect(results).to eq 'Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.'
    end

    context "with unsafe characters" do
      let!(:author_names) { [create(:author_name, name: 'Ward, P. S.')] }

      it "escapes the citation in an article reference" do
        reference = create :article_reference,
          title: 'Ants are my life', author_names: author_names,
          journal: create(:journal, name: '<script>'), citation_year: '2010d', series_volume_issue: '<', pagination: '>'
        expect(reference.decorate.formatted)
          .to eq 'Ward, P. S. 2010d. Ants are my life. &lt;script&gt; &lt;:&gt;.'
      end
    end
  end
end
