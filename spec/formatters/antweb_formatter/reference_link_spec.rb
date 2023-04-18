# frozen_string_literal: true

require 'rails_helper'

describe AntwebFormatter::ReferenceLink do
  describe "#call" do
    let(:reference) do
      create :article_reference,
        :with_doi,
        author_string: 'Latreille, P. A.',
        year: 1809,
        title: "*Atta*",
        journal: create(:journal, name: 'Science'),
        series_volume_issue: '(1)',
        pagination: '3'
    end

    context "when reference is not downloadable" do
      specify do
        allow(reference).to receive(:downloadable?).and_return false
        allow(reference).to receive(:routed_url).and_return 'example.com'

        expect(described_class[reference]).to eq(
          %{<a title="Latreille, P. A. 1809. Atta. Science (1):3." } +
          %(href="https://antcat.org/references/#{reference.id}">Latreille, 1809</a>) +
          %( <a class="external-link" href="https://doi.org/#{reference.doi}">#{reference.doi}</a>)
        )
      end
    end

    context "when reference is downloadable" do
      it "includes the PDF link" do
        allow(reference).to receive(:downloadable?).and_return true
        allow(reference).to receive(:routed_url).and_return 'example.com'

        expect(described_class[reference]).to eq(
          %{<a title="Latreille, P. A. 1809. Atta. Science (1):3." } +
          %(href="https://antcat.org/references/#{reference.id}">Latreille, 1809</a>) +
          %( <a class="external-link" href="https://doi.org/#{reference.doi}">#{reference.doi}</a>) +
          %( <a class="pdf-link" rel="nofollow" href="example.com">PDF</a>)
        )
      end
    end

    describe "handling quotes in the title" do
      let(:reference) { create :any_reference, title: '"Atta"' }

      it "escapes them" do
        expect(described_class[reference]).to include " &quot;Atta&quot;"
      end
    end
  end
end
