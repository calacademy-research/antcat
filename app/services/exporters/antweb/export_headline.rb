module Exporters
  module Antweb
    class ExportHeadline
      include ActionView::Context # For `#content_tag`.
      include ActionView::Helpers::TagHelper # For `#content_tag`.
      include Service

      def initialize taxon
        @taxon = taxon
      end

      def call
        content_tag :div do
          [
            headline_protonym,
            headline_type,
            type_fields,
            headline_notes,
            link_to_antcat,
            taxon.decorate.link_to_antwiki,
            taxon.decorate.link_to_hol
          ].compact.join(' ').html_safe
        end
      end

      private

        attr_reader :taxon

        delegate :headline_notes_taxt, to: :taxon

        def headline_protonym
          Exporters::Antweb::ExportHeadlineProtonym[taxon.protonym]
        end

        def headline_type
          Exporters::Antweb::ExportHeadlineType[taxon]
        end

        def type_fields
          Exporters::Antweb::ExportTypeFields[taxon.protonym]
        end

        def headline_notes
          return if headline_notes_taxt.blank?
          AntwebDetax[headline_notes_taxt]
        end

        def link_to_antcat
          Exporters::Antweb::Exporter.antcat_taxon_link taxon
        end
    end
  end
end
