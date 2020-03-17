require 'rails_helper'

describe Exporters::Antweb::AntwebInlineCitation do
  let(:latreille) { create :author_name, name: 'Latreille, P. A.' }
  let!(:reference) do
    create :article_reference,
      :with_doi,
      author_names: [latreille],
      citation_year: '1809',
      title: "*Atta*",
      journal: create(:journal, name: 'Science'),
      series_volume_issue: '(1)',
      pagination: '3'
  end

  before { allow(reference).to receive(:routed_url).and_return 'example.com' }

  describe "#call" do
    context "when PDF is not available to the user" do
      it "doesn't include the PDF link" do
        allow(reference).to receive(:downloadable?).and_return false

        expect(described_class[reference]).to eq(
          %{<a title="Latreille, P. A. 1809. Atta. Science (1):3." } +
          %(href="https://antcat.org/references/#{reference.id}">Latreille, 1809</a>) +
          %( <a class="external-link" href="https://doi.org/#{reference.doi}">#{reference.doi}</a>)
        )
      end
    end

    context "when PDF is available to the user" do
      it "includes the PDF link" do
        allow(reference).to receive(:downloadable?).and_return true

        expect(described_class[reference]).to eq(
          %{<a title="Latreille, P. A. 1809. Atta. Science (1):3." } +
          %(href="https://antcat.org/references/#{reference.id}">Latreille, 1809</a>) +
          %( <a class="external-link" href="https://doi.org/#{reference.doi}">#{reference.doi}</a>) +
          %( <a class="pdf-link" href="example.com">PDF</a>)
        )
      end
    end

    describe "handling quotes in the title" do
      let(:reference) { create :unknown_reference, title: '"Atta"' }

      it "escapes them" do
        expect(described_class[reference]).to include " &quot;Atta&quot;"
      end
    end
  end
end
