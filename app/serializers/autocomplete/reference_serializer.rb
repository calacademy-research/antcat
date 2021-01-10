# frozen_string_literal: true

module Autocomplete
  class ReferenceSerializer
    attr_private_initialize :reference, :fulltext_params

    def as_json include_search_query: false
      {
        id: reference.id,
        title: reference.title,
        author: reference.author_names_string_with_suffix,
        year: reference.suffixed_year_with_stated_year,
        url: "/references/#{reference.id}"
      }.tap do |hsh|
        hsh[:search_query] = formated_search_query if include_search_query
      end
    end

    def to_json options = {}
      as_json(**options).to_json
    end

    private

      def formated_search_query
        if searching_with_keywords?
          format_autosuggest_keywords
        else
          reference.title
        end
      end

      def searching_with_keywords?
        fulltext_params.size > 1
      end

      def format_autosuggest_keywords
        fulltext_params_dup = fulltext_params.dup

        replaced = []
        replaced << fulltext_params_dup[:keywords] || ''
        replaced << "author:'#{reference.author_names_string}'" if fulltext_params_dup[:author]
        replaced << "title:'#{reference.title}'" if fulltext_params_dup[:title]
        replaced << "year:#{fulltext_params_dup[:year]}" if fulltext_params_dup[:year]

        start_year = fulltext_params_dup[:start_year]
        end_year   = fulltext_params_dup[:end_year]
        if start_year && end_year
          replaced << "year:#{start_year}-#{end_year}"
        end
        replaced.join(" ").strip
      end
  end
end
