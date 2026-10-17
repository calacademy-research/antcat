# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::LinkableReferencesSerializer do
  describe "#call" do
    describe "output format" do
      context "when reference is a `NestedReference`" do
        let(:reference) { create :nested_reference, bolton_key: "Smith, 1858b" }

        specify do
          expect(described_class[[reference]]).to eq [
            {
              id: reference.id,
              author: reference.author_names_string_with_suffix,
              year: reference.suffixed_year,
              title: "#{reference.title}.",
              full_pagination: "[pagination: #{reference.pagination} (#{reference.nesting_reference.pagination})]",
              bolton_key: "[Bolton key: #{reference.bolton_key}]"
            }
          ]
        end
      end
    end

    describe "title" do
      let(:reference) { create :any_reference, title: %(*Atta* <img src="x" onerror="alert(1)">) }

      it "is escaped HTML with italics" do
        expect(described_class[[reference]].first[:title]).
          to eq %(<i>Atta</i> &lt;img src=&quot;x&quot; onerror=&quot;alert(1)&quot;&gt;.)
      end
    end
  end
end
