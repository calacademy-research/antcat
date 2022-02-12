# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::ReferenceSerializer do
  describe "#as_json" do
    let!(:reference) { create :any_reference, :with_year_suffix, :with_stated_year, author_string: 'E.O. Wilson' }

    before do
      Sunspot.commit
    end

    specify do
      expect(described_class.new(reference).as_json).to eq(
        {
          id: reference.id,
          author: "E.O. Wilson",
          title: reference.title,
          year: reference.suffixed_year_with_stated_year,
          full_pagination: reference.full_pagination,
          key_with_suffixed_year: reference.key_with_suffixed_year,
          url: "/references/#{reference.id}"
        }
      )
    end

    context 'without `include_search_query`' do
      specify do
        expect(described_class.new(reference).as_json[:search_query]).to eq nil
      end
    end

    context 'with `include_search_query`' do
      describe "autosuggest keywords" do
        subject(:serializer) do
          described_class.new(
            reference,
            References::Search::ExtractKeywords::Extracted.new(fulltext_params_hash)
          )
        end

        let(:serialized) { serializer.as_json(include_search_query: true) }

        context 'with keywords only' do
          let(:fulltext_params_hash) { { author: 'wil' } }

          it 'expands partially typed keyword values' do
            expect(serialized[:search_query]).to eq("author:'E.O. Wilson'")
          end
        end

        context 'with keywords and `freetext`' do
          let(:fulltext_params_hash) { { author: 'wil', year: 2000, freetext: 'pizza' } }

          it 'expands partially typed keyword values while keeping the `freetext`' do
            expect(serialized[:search_query]).to eq("pizza author:'E.O. Wilson' year:2000")
          end
        end

        context 'with `freetext` only' do
          let(:fulltext_params_hash) { { freetext: 'pizza' } }

          it 'uses reference title for the `search_query` attribute' do
            expect(serialized[:search_query]).to eq(reference.title)
          end
        end
      end
    end
  end
end
