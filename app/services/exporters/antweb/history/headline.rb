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
              HeadlineProtonym[taxon.protonym],
              HeadlineType[taxon],
              TypeFields[taxon.protonym],
              headline_notes,
              link_to_antcat,
              taxon.decorate.link_to_antwiki,
              taxon.decorate.link_to_hol
            ].compact.join(' ').html_safe
          end
        end

        private

          def headline_notes
            return unless taxon.headline_notes_taxt
            AntwebFormatter.detax(taxon.headline_notes_taxt)
          end

          def link_to_antcat
            AntwebFormatter.link_to_taxon_with_label(taxon, 'AntCat')
          end
      end
    end
  end
end
