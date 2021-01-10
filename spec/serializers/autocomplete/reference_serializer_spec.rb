# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::ReferenceSerializer do
  describe "#as_json" do
    let!(:reference) { create :any_reference, :with_year_suffix, :with_stated_year, author_string: 'E.O. Wilson' }

    before do
      Sunspot.commit
    end

    specify do
      expect(described_class.new(reference, { freetext: '' }).as_json(include_search_query: true)).to eq(
        {
          id: reference.id,
          author: "E.O. Wilson",
          search_query: reference.title,
          title: reference.title,
          year: reference.suffixed_year_with_stated_year,
          url: "/references/#{reference.id}"
        }
      )
    end

    context "with autosuggest keywords" do
      it 'expands partially typed keyword values' do
        serialized = described_class.new(reference, { author: 'wil', freetext: '' }).as_json(include_search_query: true)

        expect(serialized).to eq(
          {
            id: reference.id,
            author: "E.O. Wilson",
            search_query: "author:'E.O. Wilson'",
            title: reference.title,
            year: reference.suffixed_year_with_stated_year,
            url: "/references/#{reference.id}"
          }
        )
      end
    end
  end
end
