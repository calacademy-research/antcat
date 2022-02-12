# frozen_string_literal: true

module Autocomplete
  class ReferenceSerializer
    def initialize reference, fulltext_params = nil
      @reference = reference
      @fulltext_params = fulltext_params
    end

    def as_json include_search_query: false
      {
        id: reference.id,
        title: reference.title,
        author: reference.author_names_string_with_suffix,
        year: reference.suffixed_year_with_stated_year,
        key_with_suffixed_year: reference.key_with_suffixed_year_cache,
        full_pagination: reference.full_pagination,
        url: "/references/#{reference.id}"
      }.tap do |hsh|
        hsh[:search_query] = formated_search_query if include_search_query
      end
    end

    def to_json options = {}
      as_json(**options).to_json
    end

    private

      attr_reader :reference, :fulltext_params

      def formated_search_query
        return reference.title unless fulltext_params.searching_with_keywords?
        format_autosuggest_keywords
      end

      def format_autosuggest_keywords
        formatted = []

        formatted << fulltext_params.freetext if fulltext_params.freetext
        formatted << "author:'#{reference.author_names_string}'" if fulltext_params.author
        formatted << "title:'#{reference.title}'" if fulltext_params.title
        formatted << "year:#{fulltext_params.year}" if fulltext_params.year

        start_year = fulltext_params.start_year
        end_year = fulltext_params.end_year
        if start_year && end_year
          formatted << "year:#{start_year}-#{end_year}"
        end

        formatted.join(" ").strip
      end
  end
end
