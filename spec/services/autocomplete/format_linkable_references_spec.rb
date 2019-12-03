require 'rails_helper'

describe Autocomplete::FormatLinkableReferences do
  describe "#call" do
    describe "output format" do
      context "when a nested reference" do
        let(:reference) { create :nested_reference, bolton_key: "Smith, 1858b" }

        specify do
          expect(described_class[[reference]]).to eq [
            {
              id: reference.id,
              author: reference.author_names_string_with_suffix,
              year: reference.citation_year,
              title: "#{reference.title}.",
              full_pagination: "[pagination: #{reference.pages_in} (#{reference.nesting_reference.pagination})]",
              bolton_key: "[Bolton key: #{reference.bolton_key}]"
            }
          ]
        end
      end
    end
  end
end
