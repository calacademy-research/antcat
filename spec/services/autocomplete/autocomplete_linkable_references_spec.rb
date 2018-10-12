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
            author: reference.author_names_string_with_suffix,
            year: reference.citation_year,
            title: "#{reference.title}.",
            full_pagination: "[pagination: #{reference.pages_in} (22 pp.)]",
            bolton_key: "[Bolton key: #{reference.bolton_key}]"
          }
        ]
      end
    end
  end
end
