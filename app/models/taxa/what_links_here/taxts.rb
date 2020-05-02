# frozen_string_literal: true

module Taxa
  class WhatLinksHere
    class Taxts
      include Service

      attr_private_initialize :taxon, [predicate: false]

      def call
        if predicate
          any_table_refs?
        else
          table_refs
        end
      end

      private

        def any_table_refs?
          Taxt::TAXTABLES.each do |(model, _table, field)|
            model.where("#{field} REGEXP ?", Taxt.tax_or_taxac_tag_regex(taxon)).pluck(:id).each do |matched_id|
              next if exclude_taxt_match? model, matched_id
              return true
            end
          end

          false
        end

        def table_refs
          table_refs = []
          Taxt::TAXTABLES.each do |(model, _table, field)|
            model.where("#{field} REGEXP ?", Taxt.tax_or_taxac_tag_regex(taxon)).pluck(:id).each do |matched_id|
              next if exclude_taxt_match? model, matched_id
              table_refs << table_ref(model.table_name, field.to_sym, matched_id)
            end
          end
          table_refs
        end

        def exclude_taxt_match? model, matched_id
          return true if model == Taxon && matched_id == taxon.id
          false
        end

        def table_ref table, field, id
          TableRef.new(table, field, id)
        end
    end
  end
end
