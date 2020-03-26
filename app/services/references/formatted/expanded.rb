# frozen_string_literal: true

# Formats the reference with HTML, CSS, etc.

module References
  module Formatted
    class Expanded
      include ActionView::Helpers::SanitizeHelper
      include Rails.application.routes.url_helpers
      include ActionView::Helpers::UrlHelper
      include Service

      def initialize reference
        @reference = reference
      end

      def call
        string = author_names_with_links
        string << ' '
        string << sanitize(reference.citation_year) << '. '
        string << link_to(reference.decorate.format_title, reference_path(reference)) << ' '
        string << format_italics(AddPeriodIfNecessary[sanitize(format_citation)])
        string << ' [online early]' if reference.online_early?

        string
      end

      private

        attr_reader :reference

        def author_names_with_links
          string =  reference.author_names.map do |author_name|
                      link_to(sanitize(author_name.name), author_path(author_name.author))
                    end.join('; ')

          string << sanitize(" #{reference.author_names_suffix}") if reference.author_names_suffix.present?
          string.html_safe
        end

        def format_citation
          case reference
          when ::ArticleReference
            "#{reference.journal.name} #{reference.series_volume_issue}:#{reference.pagination}"
          when ::BookReference
            "#{reference.publisher.display_name}, #{reference.pagination}"
          when ::NestedReference
            "#{reference.pagination} #{sanitize References::Formatted::Expanded[reference.nesting_reference]}"
          when ::MissingReference, ::UnknownReference
            reference.citation
          else
            raise
          end
        end

        def format_italics string
          References::FormatItalics[string]
        end
    end
  end
end
