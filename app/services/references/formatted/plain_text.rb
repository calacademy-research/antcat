# frozen_string_literal: true

# Formats the reference as plaintext (with the exception of <i> tags).

module References
  module Formatted
    class PlainText
      include ActionView::Helpers::SanitizeHelper
      include Service

      attr_private_initialize :reference

      def call
        string = sanitize(reference.author_names_string_with_suffix)
        string << ' '
        string << sanitize(reference.suffixed_year_with_stated_year) << '. '
        string << Unitalicize[reference.decorate.format_title] << ' '
        string << AddPeriodIfNecessary[sanitize(format_citation)]
        string
      end

      private

        def format_citation
          case reference
          when ::ArticleReference
            "#{reference.journal.name} #{reference.series_volume_issue}:#{reference.pagination}"
          when ::BookReference
            "#{reference.publisher.display_name}, #{reference.pagination}"
          when ::NestedReference
            "#{reference.pagination} #{References::Formatted::PlainText[reference.nesting_reference]}"
          else
            raise 'unknown type'
          end
        end
    end
  end
end
