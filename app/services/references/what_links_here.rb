# frozen_string_literal: true

module References
  class WhatLinksHere
    include Service

    attr_private_initialize :reference, [predicate: false]

    def call
      if predicate
        any_table_refs?
      else
        table_refs
      end
    end

    private

      attr_reader :reference, :predicate

      delegate :nestees, :citations, to: :reference, private: true

      def any_table_refs?
        Taxt::TAXTABLES.each do |(model, _table, field)|
          return true if model.where("#{field} REGEXP ?", Taxt.ref_tag_regex(reference)).exists?
        end

        citations.exists? || nestees.exists?
      end

      def table_refs
        table_refs = []

        Taxt::TAXTABLES.each do |(model, _table, field)|
          model.where("#{field} REGEXP ?", Taxt.ref_tag_regex(reference)).pluck(:id).each do |matched_id|
            table_refs << table_ref(model.table_name, field.to_sym, matched_id)
          end
        end

        citations.pluck(:id).each do |citation_id|
          table_refs << table_ref(Citation.table_name, :reference_id, citation_id)
        end

        nestees.pluck(:id).each do |reference_id|
          table_refs << table_ref('references', :nesting_reference_id, reference_id)
        end

        table_refs
      end

      def table_ref table, field, id
        TableRef.new(table, field, id)
      end
  end
end
