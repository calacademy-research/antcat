require "spec_helper"

describe References::Search::FulltextLight do
  describe "ordering", search: true do
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
