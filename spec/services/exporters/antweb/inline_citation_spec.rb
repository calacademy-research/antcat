require "spec_helper"

describe Exporters::Antweb::InlineCitation do
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

  describe "#call" do
    context "when expansion is not desired" do
      context "PDF is not available to the user" do
        it "doesn't include the PDF link" do
          allow(reference).to receive(:downloadable?).and_return false

          expect(described_class[reference]).to eq(
            %{<a title="Latreille, P. A. 1809. Atta. Science (1):3." } +
            %{href="http://antcat.org/references/#{reference.id}">Latreille, 1809</a>} +
            %{ <a href="http://dx.doi.org/10.10.1038/nphys1170">10.10.1038/nphys1170</a>}
          )
        end
      end

      context "when PDF is available to the user" do
        it "includes the PDF link" do
          allow(reference).to receive(:downloadable?).and_return true

          expect(described_class[reference]).to eq(
            %{<a title="Latreille, P. A. 1809. Atta. Science (1):3." } +
            %{href="http://antcat.org/references/#{reference.id}">Latreille, 1809</a>} +
            %{ <a href="http://dx.doi.org/10.10.1038/nphys1170">10.10.1038/nphys1170</a>} +
            %{ <a href="example.com">PDF</a>}
          )
        end
      end
    end

    describe "Handling quotes in the title" do
      let(:reference) do
        create :unknown_reference, author_names: [latreille],
          citation_year: '1809', title: '"Atta"'
      end

      it "escapes them" do
        expect(described_class[reference]).to eq(
          %{<a title="Latreille, P. A. 1809. &quot;Atta&quot;. New York." href="http://antcat.org/references/#{reference.id}">Latreille, 1809</a>}
        )
      end
    end
  end
end
