require 'spec_helper'

describe ArticleReferenceDecorator do
  let(:author_name) { create :author_name, name: "Forel, A." }
  let!(:reference) do
    create :article_reference, author_names: [author_name], citation_year: '1874',
      title: "*Atta* <i>and such</i>",
      series_volume_issue: '(1)', pagination: '3', doi: "10.10.1038/nphys1170"
  end

  describe "#plain_text" do
    specify { expect(reference.decorate.plain_text).to be_html_safe }

    specify do
      results = reference.decorate.plain_text
      expect(results).to be_html_safe
      expect(results).to eq "Forel, A. 1874. Atta and such. #{reference.journal.name} (1):3."
    end

    context "with unsafe characters" do
      let(:reference) {  create :article_reference, journal: create(:journal, name: '<script>') }

      it "escapes them" do
        expect(reference.decorate.plain_text).to include '&lt;script&gt;'
      end
    end
  end

  describe "#expanded_reference" do
    specify { expect(reference.decorate.expanded_reference).to be_html_safe }

    specify do
      expect(reference.decorate.expanded_reference).to eq <<~HTML.squish
        Forel, A. 1874. <i>Atta</i> <i>and such</i>. #{reference.journal.name} (1):3.
      HTML
    end
  end

  describe "#expandable_reference" do
    before do
      allow(reference).to receive(:url).and_return 'example.com'
      allow(reference).to receive(:downloadable?).and_return true
    end

    specify do
      expect(reference.decorate.expandable_reference).to eq(
        %(<span class="expandable-reference">) +
          %{<a title="Forel, A. 1874. Atta and such. #{reference.journal.name} (1):3." class="expandable-reference-key" href="#">Forel, 1874</a>} +
          %(<span class="expandable-reference-content">) +
            %{<span class="expandable-reference-text">Forel, A. 1874. <i>Atta</i> <i>and such</i>. #{reference.journal.name} (1):3.</span> } +
            %(<a class="external-link" href="https://doi.org/#{reference.doi}">#{reference.doi}</a> ) +
            %(<a class="external-link" href="example.com">PDF</a> ) +
            %(<a class="btn-normal btn-tiny" href="/references/#{reference.id}">#{reference.id}</a>) +
          %(</span>) +
        %(</span>)
      )
    end

    xspecify do
      expect(reference.decorate.expandable_reference).to eq(
        %(<span class="expandable-reference">) +
          %{<a title="Forel, A. 1874. Atta and such. #{reference.journal.name} (1):3." class="expandable-reference-key" href="#">Forel, 1874</a>} +
          %(<span class="expandable-reference-content">) +
            %{<span class="expandable-reference-text">Forel, A. 1874. <a href="/references/#{reference.id}"><i>Atta</i> <i>and such</i>.</a> #{reference.journal.name} (1):3.</span> } +
            %(<a class="external-link" href="https://doi.org/#{reference.doi}">#{reference.doi}</a> ) +
            %(<a class="external-link" href="example.com">PDF</a> ) +
            %(<a class="btn-normal btn-tiny" href="/references/#{reference.id}">#{reference.id}</a>) +
          %(</span>) +
        %(</span>)
      )
    end
  end
end
