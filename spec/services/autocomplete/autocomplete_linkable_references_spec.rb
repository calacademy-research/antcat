require "spec_helper"

describe Autocomplete::AutocompleteLinkableReferences do
  describe "output format" do
    context "when a nested reference" do
      let(:search_query) { "" }
      let(:service) { described_class.new(search_query) }
      let(:reference) do
        create :nested_reference, pages_in: "Pp. 105-111 in:", bolton_key: "Smith, 1858b"
      end

      before do
        allow(service).to receive(:search_results).and_return [reference]
      end

      specify do
        expect(service.call).to eq [
          {
            id: reference.id,
            author: reference.author_names_string,
            year: reference.citation_year,
            title: "#{reference.title}.",
            full_pagination: "[pagination: #{reference.pages_in} (22 pp.)]",
            bolton_key: "[Bolton key: #{reference.bolton_key}]"
          }
        ]
      end
    end
  end

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

        expect(service.call.map { |reference| reference[:id] }).to eq [
          forel_a.id,
          forel_b.id
        ]
      end

      context "when there is also a less relevant hit" do
        it "orders by citation year and places less relevant hits last" do
          # Trigger `let`s.
          [less_relevant, forel_b, forel_a] # rubocop:disable Lint/Void
          Sunspot.commit

          expect(service.call.map { |reference| reference[:id] }).to eq [
            forel_a.id,
            forel_b.id,
            less_relevant.id
          ]
        end
      end
    end
  end
end
