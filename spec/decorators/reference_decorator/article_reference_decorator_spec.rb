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

  describe "#inline_citation" do
    let(:latreille) { create :author_name, name: 'Latreille, P. A.' }
    let!(:reference) do
      create :article_reference,
        author_names: [latreille],
        citation_year: '1809',
        title: "*Atta*",
        journal: create(:journal, name: 'Science'),
        series_volume_issue: '(1)',
        pagination: '3'
    end

    before { allow(reference).to receive(:url).and_return 'example.com' }

    it "creates a link to the reference" do
      allow(reference).to receive(:downloadable?).and_return true

      expect(reference.decorate.inline_citation).to eq(
        %{<span class="reference_keey_and_expansion">} +
          %{<a title="Latreille, P. A. 1809. Atta. Science (1):3." class="reference_keey" href="#">Latreille, 1809</a>} +
          %{<span class="reference_keey_expansion">} +
            %{<span class="reference_keey_expansion_text" title="Latreille, 1809">Latreille, P. A. 1809. <i>Atta</i>. Science (1):3.</span>} +
            %{ } +
            %{<a href="http://dx.doi.org/10.10.1038/nphys1170">10.10.1038/nphys1170</a> } +
            %{<a href="example.com">PDF</a>} +
            %{ } +
            %{<a class="btn-normal btn-tiny" href="/references/#{reference.id}">#{reference.id}</a>} +
          %{</span>} +
        %{</span>}
      )
    end
  end
end
