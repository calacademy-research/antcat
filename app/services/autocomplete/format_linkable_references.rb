# frozen_string_literal: true

module Autocomplete
  class FormatLinkableReferences
    include Service

    attr_private_initialize :references

    def call
      references.map do |reference|
        {
          id: reference.id,
          author: reference.author_names_string_with_suffix,
          year: reference.citation_year_and_stated_year,
          title: reference.decorate.format_title,
          full_pagination: full_pagination(reference),
          bolton_key: bolton_key(reference)
        }
      end
    end

    private

      def full_pagination reference
        if reference.is_a? NestedReference
          "[pagination: #{reference.pagination} (#{reference.nesting_reference.pagination})]"
        elsif reference.pagination
          "[pagination: #{reference.pagination}]"
        else
          ""
        end
      end

      def bolton_key reference
        return "" unless reference.bolton_key
        "[Bolton key: #{reference.bolton_key}]"
      end
  end
end
