# frozen_string_literal: true

module Exporters
  module Antweb
    module History
      class Headline
        include ActionView::Context # For `#content_tag`.
        include ActionView::Helpers::TagHelper # For `#content_tag`.
        include Service

        attr_private_initialize :taxon

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

          delegate :headline_notes_taxt, to: :taxon, private: true

          def headline_protonym
            Exporters::Antweb::History::Headline::HeadlineProtonym[taxon.protonym]
          end

          def headline_type
            Exporters::Antweb::History::Headline::HeadlineType[taxon]
          end

          def type_fields
            Exporters::Antweb::History::Headline::TypeFields[taxon.protonym]
          end

          def headline_notes
            return unless headline_notes_taxt
            AntwebDetax[headline_notes_taxt]
          end

          def link_to_antcat
            AntwebFormatter.link_to_taxon_with_label(taxon, 'AntCat')
          end
      end
    end
  end
end
