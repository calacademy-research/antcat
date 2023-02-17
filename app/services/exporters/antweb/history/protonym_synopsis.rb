# frozen_string_literal: true

module Exporters
  module Antweb
    module History
      class ProtonymSynopsis
        include ActionView::Context # For `#tag`.
        include ActionView::Helpers::TagHelper # For `#tag`.
        include Service

        attr_private_initialize :taxon

        def call
          tag.div do
            [
              ProtonymLine[taxon.protonym],
              TypeNameLine[taxon.protonym],
              TypeFields[taxon.protonym],
              link_to_antcat,
              taxon.decorate.link_to_antwiki,
              taxon.decorate.link_to_hol
            ].compact.join(' ').html_safe
          end
        end

        private

          def link_to_antcat
            AntwebFormatter.link_to_taxon_with_label(taxon, 'AntCat')
          end
      end
    end
  end
end
