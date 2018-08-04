require "spec_helper"

describe References::Search::FulltextLight, :search do
  describe "search queries" do
    context "when search query contains hyphens" do
      let!(:reference) { reference_factory author_name: "Casevitz-Weulersse" }

      before { Sunspot.commit }

      specify { expect(described_class["Casevitz-Weulersse"]).to eq [reference] }
      specify { expect(described_class["Casevitz Weulersse"]).to eq [reference] }
    end

    context "when search query contains 'et al.'" do
      let!(:reference) do
        bolton = create :author_name, name: 'Bolton, B.'
        fisher = create :author_name, name: 'Fisher, B.'
        ward = create :author_name, name: 'Ward, P.S.'

        # The reference's key will contain "et al".
        create :article_reference, author_names: [bolton, fisher, ward], citation_year: '1970a'
      end

      before { Sunspot.commit }

      specify { expect(described_class["Fisher, et al. 1970a"]).to eq [reference] }
    end
  end

  describe "ordering" do
    let(:service) { described_class.new("Forel 1911") }
    let(:forel_a) { reference_factory author_name: "Forel", citation_year: "1911a" }
    let(:forel_b) { reference_factory author_name: "Forel", citation_year: "1911b" }
    let(:less_relevant) do
      reference_factory author_name: "Other", citation_year: "1912", title: "Forel 1911 was here"
    end

    context "when references have the same year but different citation years" do
      it "orders by citation year" do
        # Trigger `let`s.
        [forel_b, forel_a] # rubocop:disable Lint/Void
        Sunspot.commit

        expect(service.call).to eq [forel_a, forel_b]
      end

      context "when there is also a less relevant hit" do
        it "orders by citation year and places less relevant hits last" do
          # Trigger `let`s.
          [less_relevant, forel_b, forel_a] # rubocop:disable Lint/Void
          Sunspot.commit

          expect(service.call).to eq [forel_a, forel_b, less_relevant]
        end
      end
    end
  end
end
