# frozen_string_literal: true

module Exporters
  module Antweb
    class TaxonAttributes
      include ActionView::Context # For `#tag`.
      include ActionView::Helpers::TagHelper # For `#tag`.
      include Service

      FORMICIDAE = 'Formicidae'
      UNAVAILABLE_STATUSES = [Status::UNAVAILABLE, Status::UNAVAILABLE_MISSPELLING]
      MAX_CHAIN_LENGTH = 20

      # The meaning of each column and how AntWeb reads it: docs/antweb_export.md.

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
            authors:                  taxon.authorship_reference.key.authors_for_key,
            year:                     taxon.authorship_reference.year,
            status:                   taxon.status,
            available:                available?,
            current_valid_name:       current_valid_name,
            original_combination:     taxon.original_combination?,
            was_original_combination: original_combination&.name&.name,
            fossil:                   taxon.protonym.fossil?,
            taxonomic_history_html:   taxonomic_history_html,
            reference_id:             taxon.authorship_reference.id,
            bioregion:                taxon.protonym.bioregion,
            country:                  taxon.protonym.locality,
            current_valid_rank:       taxon.class.to_s,
            hol_id:                   taxon.hol_id,
            current_valid_parent:     current_valid_parent&.name&.name || FORMICIDAE
          }
        end

        def taxonomic_attributes
          @_taxonomic_attributes ||= Exporters::Antweb::TaxonomicAttributes[taxon]
        end

        def authorship_html_string
          reference = taxon.authorship_reference
          tag.span reference.key_with_suffixed_year, title: reference.decorate.plain_text
        end

        # Nomenclatural availability, not validity: junior synonyms, homonyms and unidentifiable
        # names are available. Not available: a nomen nudum protonym, the statuses "unavailable"
        # and "unavailable misspelling", and an obsolete combination of an unavailable name.
        def available?
          return false if taxon.protonym.nomen_nudum?

          name_bearer = taxon
          MAX_CHAIN_LENGTH.times do
            break unless name_bearer.status == Status::OBSOLETE_COMBINATION && name_bearer.current_taxon
            name_bearer = name_bearer.current_taxon
          end

          !name_bearer.status.in?(UNAVAILABLE_STATUSES)
        end

        # The taxon this name now belongs to: `current_taxon` followed to the end (a synonym's
        # `current_taxon` can itself be an obsolete combination or a synonym). The taxon itself
        # when it has no `current_taxon`.
        def now_taxon
          @_now_taxon ||= taxon.now_taxon
        end

        # Column 13. Empty when the taxon has no `current_taxon`. Otherwise the now taxon's name
        # in the form AntWeb builds its taxon names from: the subfamily of the now taxon (not of the
        # exported taxon), a space, then the full name. Family and subfamily: the name alone.
        def current_valid_name
          return unless taxon.current_taxon

          valid_taxon = now_taxon
          return valid_taxon.name.name if valid_taxon.is_a?(Family) || valid_taxon.is_a?(Subfamily)

          "#{subfamily_of(valid_taxon)} #{valid_taxon.name.name}"
        end

        # Ranks that `TaxonomicAttributes` does not export (subtribe, infrasubspecies) fall back to the
        # exported taxon's own subfamily.
        def subfamily_of valid_taxon
          return taxonomic_attributes[:subfamily] if valid_taxon.is_a?(Subtribe) || valid_taxon.is_a?(Infrasubspecies)
          Exporters::Antweb::TaxonomicAttributes[valid_taxon][:subfamily]
        end

        def original_combination
          taxon.class.where(original_combination: true, current_taxon: taxon).first
        end

        def taxonomic_history_html
          valid_only_statistics = ::Taxa::Statistics::FetchStatistics[taxon, valid_only: true]

          tag.div class: 'antcat_taxon' do # NOTE: `.antcat_taxon` is used on AntWeb.
            content = ''.html_safe
            content << ::Taxa::Statistics::FormatStatistics[valid_only_statistics]
            content << Exporters::Antweb::History::ProtonymSynopsis[taxon]
            content << Exporters::Antweb::History::HistoryItems[taxon]
            content << Exporters::Antweb::History::ChildList[taxon]
            content << Exporters::Antweb::History::ReferenceSections[taxon]
          end
        end

        # Column 23. The parent of the now taxon (the same taxon as column 13; the taxon itself when
        # it has no `current_taxon`), with subgenera skipped, followed to its own now taxon.
        # `nil` (exported as Formicidae) at the top.
        def current_valid_parent
          parent = now_taxon.parent
          return unless parent

          parent = parent.parent if parent.is_a?(Subgenus)
          parent&.now_taxon
        end
    end
  end
end
