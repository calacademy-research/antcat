# frozen_string_literal: false

# TODO: Strings are not frozen due to `col.delete!("\n")` in `Exporters::Antweb::Exporter`.

module Exporters
  module Antweb
    class ExportTaxon
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
        remove_newlines(antweb_array)
      end

      private

        def remove_newlines array
          array.each do |value|
            if value.is_a? String
              value.delete!("\n")
              value.delete!("\r")
            end
          end
        end

        def antweb_array
          convert_to_antweb_array(Exporters::Antweb::TaxonAttributes[taxon])
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
            values[:current_valid_name],
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
    end
  end
end
