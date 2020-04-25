# frozen_string_literal: true

# Formats the reference with HTML, CSS, etc.

module References
  module Formatted
    class Expanded
      include ActionView::Helpers::SanitizeHelper
      include Rails.application.routes.url_helpers
      include ActionView::Helpers::UrlHelper
      include Service

      attr_private_initialize :reference

      def call
        string = author_names_with_links
        string << ' '
        string << sanitize(reference.citation_year_with_stated_year) << '. '
        string << link_to(reference.decorate.format_title, reference_path(reference)) << ' '
        string << AddPeriodIfNecessary[sanitize(format_citation)]
        string << ' [online early]' if reference.online_early?

        string
      end

      private

        def author_names_with_links
          string =  reference.author_names.map do |author_name|
                      link_to(sanitize(author_name.name), author_path(author_name.author))
                    end.join('; ')

          string << sanitize(" #{reference.author_names_suffix}") if reference.author_names_suffix
          string.html_safe
        end

        def format_citation
          case reference
          when ::ArticleReference
            "#{reference.journal.name} #{reference.series_volume_issue}:#{reference.pagination}"
          when ::BookReference
            "#{reference.publisher.display_name}, #{reference.pagination}"
          when ::NestedReference
            "#{reference.pagination} #{References::Formatted::Expanded[reference.nesting_reference]}"
          end
        end
    end
  end
end
