# frozen_string_literal: true

module Taxa
  class WhatLinksHereColumns
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
        Taxt::TAXA_FIELDS_REFERENCING_TAXA.each do |field|
          return true if Taxon.where(field => taxon.id).exists?
        end
        false
      end

      def table_refs
        table_refs = []
        Taxt::TAXA_FIELDS_REFERENCING_TAXA.each do |field|
          Taxon.where(field => taxon.id).pluck(:id).each do |matched_id|
            table_refs << table_ref('taxa', field, matched_id)
          end
        end
        table_refs
      end

      def table_ref table, field, id
        TableRef.new(table, field, id)
      end
  end
end
