# frozen_string_literal: true

module Exporters
  module Antweb
    class ExportHeadlineProtonym
      include ActionView::Context # For `#content_tag`.`
      include ActionView::Helpers::TagHelper # For `#content_tag`.`
      include Service

      def initialize protonym
        @protonym = protonym
      end

      def call
        AddPeriodIfNecessary[headline_protonym]
      end

      private

        attr_reader :protonym

        def headline_protonym
          [
            protonym_name,
            authorship(protonym.authorship),
            ('[sic]' if protonym.sic?),
            protonym.decorate.format_locality
          ].compact.join(" ").html_safe
        end

        def protonym_name
          content_tag :b do
            protonym.decorate.format_name
          end
        end

        def authorship authorship
          string = link_to_reference authorship.reference
          string << ": "
          string << protonym.decorate.format_pages_and_forms

          if authorship.notes_taxt.present?
            string << ' ' << AntwebDetax[authorship.notes_taxt]
          end

          string
        end

        def link_to_reference reference
          Exporters::Antweb::AntwebInlineCitation[reference]
        end
    end
  end
end
