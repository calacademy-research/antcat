# frozen_string_literal: true

module Autocomplete
  class LinkableReferencesSerializer
    include Service

    attr_private_initialize :references

    def call
      references.map do |reference|
        {
          id: reference.id,
          author: reference.author_names_string_with_suffix,
          year: reference.suffixed_year_with_stated_year,
          title: title(reference),
          full_pagination: full_pagination(reference),
          bolton_key: bolton_key(reference)
        }
      end
    end

    private

      # HTML: the title is escaped, then `*italics*` become `<i>` tags. The other fields are plain text.
      def title reference
        References::FormatItalics[ERB::Util.html_escape(AddPeriodIfNecessary[reference.title])]
      end

      def full_pagination reference
        "[pagination: #{reference.full_pagination}]"
      end

      def bolton_key reference
        return "" unless reference.bolton_key
        "[Bolton key: #{reference.bolton_key}]"
      end
  end
end
