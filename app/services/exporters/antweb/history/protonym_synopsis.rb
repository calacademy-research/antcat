# frozen_string_literal: true

# AntWeb export: the HTML synopsis of a taxon's protonym (name, authorship, type and locality), for the taxonomic
# history column.
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
              taxon.decorate.link_to_antwiki
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
