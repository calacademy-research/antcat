# frozen_string_literal: false

# TODO: Strings are not frozen due to `col.delete!("\n")` in `Exporters::Antweb::Exporter`.

module Exporters
  module Antweb
    class ExportTaxon # rubocop:disable Metrics/ClassLength
      include ActionView::Context # For `#content_tag`.
      include ActionView::Helpers::TagHelper # For `#content_tag`.
      include Service

      HEADER = [
        "antcat id",                #  [0]
        "subfamily",                #  [1]
        "tribe",                    #  [2]
        "genus",                    #  [3]
        "subgenus",                 #  [4]
        "species",                  #  [5]
        "subspecies",               #  [6]
        "author date",              #  [7]
        "author date html",         #  [8]
        "authors",                  #  [9]
        "year",                     # [10]
        "status",                   # [11]
        "available",                # [12]
        "current valid name",       # [13]
        "original combination",     # [14]
        "was original combination", # [15]
        "fossil",                   # [16]
        "taxonomic history html",   # [17]
        "reference id",             # [18]
        "bioregion",                # [19]
        "country",                  # [20]
        "current valid rank",       # [21]
        "hol id",                   # [22]
        "current valid parent"      # [23]
      ].join("\t")

      attr_private_initialize :taxon

      def call
        convert_to_antweb_array attributes
      end

      private

        def attributes
          {
            antcat_id:                taxon.id,
            subfamily:                nil,
            tribe:                    nil,
            genus:                    nil,
            subgenus:                 nil,
            species:                  nil,
            subspecies:               nil,
            author_date:              taxon.author_citation,
            author_date_html:         authorship_html_string,
            authors:                  taxon.authorship_reference.authors_for_keey,
            year:                     taxon.authorship_reference.year,
            status:                   taxon.status,
            available:                taxon.valid_status?,
            current_valid_name:       taxon.current_valid_taxon&.name&.name,
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
          }.merge(Exporters::Antweb::AntwebAttributes[taxon])
        end

        def convert_to_antweb_array values
          [
            values[:antcat_id],
            values[:subfamily],
            values[:tribe],
            values[:genus],
            values[:subgenus],
            values[:species],
            values[:subspecies],
            values[:author_date],
            values[:author_date_html],
            values[:authors],
            values[:year],
            values[:status],
            boolean_to_antweb(values[:available]),
            add_subfamily_to_current_valid(values[:subfamily], values[:current_valid_name]),
            boolean_to_antweb(values[:original_combination]),
            values[:was_original_combination],
            boolean_to_antweb(values[:fossil]),
            values[:taxonomic_history_html],
            values[:reference_id],
            values[:bioregion],
            values[:country],
            values[:current_valid_rank],
            values[:hol_id],
            values[:current_valid_parent]
          ]
        end

        def boolean_to_antweb boolean
          case boolean
          when true  then 'TRUE'
          when false then 'FALSE'
          when nil   then nil
          else            raise
          end
        end

        def add_subfamily_to_current_valid subfamily, current_valid_name
          return unless current_valid_name
          "#{subfamily} #{current_valid_name}"
        end

        def authorship_html_string
          reference = taxon.authorship_reference
          content_tag :span, reference.keey, title: reference.decorate.plain_text
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
