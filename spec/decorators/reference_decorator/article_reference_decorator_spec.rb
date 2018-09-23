require 'spec_helper'

describe ArticleReferenceDecorator do
  describe "#plain_text" do
    let(:author_name) { create :author_name, name: "Forel, A." }

    it "formats the reference" do
      reference = create :article_reference, author_names: [author_name], citation_year: "1874",
        title: "Les fourmis", series_volume_issue: "26", pagination: "1-452"
      results = reference.decorate.plain_text
      expect(results).to be_html_safe
      expect(results).to eq "Forel, A. 1874. Les fourmis. #{reference.journal.name} 26:1-452."
    end

    context "with unsafe characters" do
      let(:reference) {  create :article_reference, journal: create(:journal, name: '<script>') }

      it "escapes them" do
        expect(reference.decorate.plain_text).to include '&lt;script&gt;'
      end
    end
  end

  describe "#expandable_reference" do
    let(:latreille) { create :author_name, name: 'Latreille, P. A.' }
    let!(:reference) do
      create :article_reference, author_names: [latreille], citation_year: '1809', title: "*Atta*",
        series_volume_issue: '(1)', pagination: '3', doi: "10.10.1038/nphys1170"
    end

    before { allow(reference).to receive(:url).and_return 'example.com' }

    it "creates a link to the reference" do
      allow(reference).to receive(:downloadable?).and_return true

      expect(reference.decorate.expandable_reference).to eq(
        %(<span class="expandable-reference">) +
          %{<a title="Latreille, P. A. 1809. Atta. #{reference.journal.name} (1):3." class="expandable-reference-key" href="#">Latreille, 1809</a>} +
          %(<span class="expandable-reference-content">) +
            %{<span class="expandable-reference-text">Latreille, P. A. 1809. <i>Atta</i>. #{reference.journal.name} (1):3.</span> } +
            %(<a href="http://dx.doi.org/#{reference.doi}">#{reference.doi}</a> ) +
            %(<a href="example.com">PDF</a> ) +
            %(<a class="btn-normal btn-tiny" href="/references/#{reference.id}">#{reference.id}</a>) +
          %(</span>) +
        %(</span>)
      )
    end
  end
end
