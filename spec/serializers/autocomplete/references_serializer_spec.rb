# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::ReferencesSerializer do
  describe "#call" do
    let!(:reference) { create :any_reference, author_string: 'E.O. Wilson' }

    before do
      Sunspot.commit
    end

    specify do
      expect(described_class[[reference], { freetext: '' }]).to eq(
        [
          {
            id: reference.id,
            author: "E.O. Wilson",
            search_query: reference.title,
            title: reference.title,
            year: reference.citation_year,
            url: "/references/#{reference.id}"
          }
        ]
      )
    end

    describe "formatting autosuggest keywords" do
      it 'expands partially typed keyword values' do
        expect(described_class[[reference], { author: 'wil', freetext: '' }]).to eq(
          [
            {
              id: reference.id,
              author: "E.O. Wilson",
              search_query: "author:'E.O. Wilson'",
              title: reference.title,
              year: reference.citation_year,
              url: "/references/#{reference.id}"
            }
          ]
        )
      end
    end
  end
end
