require "spec_helper"

describe Autocomplete::FormatLinkableReferences do
  describe "#call" do
    describe "output format" do
      context "when a nested reference" do
        let(:reference) do
          create :nested_reference, pages_in: "Pp. 105-111 in:", bolton_key: "Smith, 1858b"
        end

        specify do
          expect(described_class[[reference]]).to eq [
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
end
