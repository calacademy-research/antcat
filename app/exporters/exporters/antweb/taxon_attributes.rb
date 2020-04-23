# frozen_string_literal: false

# TODO: Strings are not frozen due to `col.delete!("\n")` in `Exporters::Antweb::Exporter`.

module Exporters
  module Antweb
    class TaxonAttributes
      include ActionView::Context # For `#content_tag`.
      include ActionView::Helpers::TagHelper # For `#content_tag`.
      include Service

      attr_private_initialize :taxon

      def call
        attributes
      end

      private

        def attributes
          {
            antcat_id:                taxon.id,
            subfamily:                taxonomic_attributes[:subfamily],
            tribe:                    taxonomic_attributes[:tribe],
            genus:                    taxonomic_attributes[:genus],
            subgenus:                 taxonomic_attributes[:subgenus],
            species:                  taxonomic_attributes[:species],
            subspecies:               taxonomic_attributes[:subspecies],
            author_date:              taxon.author_citation,
            author_date_html:         authorship_html_string,
            authors:                  taxon.authorship_reference.key.authors_for_keey,
            year:                     taxon.authorship_reference.year,
            status:                   taxon.status,
            available:                taxon.valid_status?,
            current_valid_name:       current_valid_name,
            original_combination:     taxon.original_combination?,
            was_original_combination: original_combination&.name&.name,
            fossil:                   taxon.fossil?,
            taxonomic_history_html:   export_history,
            reference_id:             taxon.authorship_reference.id,
            bioregion:                taxon.protonym.biogeographic_region,
            country:                  taxon.protonym.locality,
            current_valid_rank:       taxon.class.to_s,
            hol_id:                   taxon.hol_id,
            current_valid_parent:     current_valid_parent&.name&.name || 'Formicidae'
          }
        end

        def taxonomic_attributes
          @_taxonomic_attributes = Exporters::Antweb::TaxonomicAttributes[taxon]
        end

        def authorship_html_string
          reference = taxon.authorship_reference
          content_tag :span, reference.keey, title: reference.decorate.plain_text
        end

        def current_valid_name
          return unless (current_valid_name = taxon.current_valid_taxon&.name&.name)
          "#{taxonomic_attributes[:subfamily]} #{current_valid_name}"
        end

        def original_combination
          taxon.class.where(original_combination: true, current_valid_taxon: taxon).first
        end

        def export_history
          content_tag :div, class: 'antcat_taxon' do # NOTE: `.antcat_taxon` is used on AntWeb.
            content = ''.html_safe
            content << taxon.decorate.statistics(valid_only: true)
            content << Exporters::Antweb::History::Headline[taxon]
            content << Exporters::Antweb::History::HistoryItems[taxon]
            content << Exporters::Antweb::History::ChildList[taxon]
            content << Exporters::Antweb::History::ReferenceSections[taxon]
          end
        end

        def current_valid_parent
          return unless taxon.parent
          parent = taxon.parent.is_a?(Subgenus) ? taxon.parent.parent : taxon.parent
          parent.current_valid_taxon || parent
        end
    end
  end
end
