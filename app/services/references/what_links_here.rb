# References to a reference.
# NOTE Expensive method.

module References
  class WhatLinksHere
    include Service

    def initialize reference, predicate: false
      @reference = reference
      @predicate = predicate
      @references = []
    end

    def call
      Taxt.models_with_taxts.each_field do |field, model|
        model.where("#{field} LIKE '%{ref #{reference.id}}%'").pluck(:id).each do |id|
          references << table_ref(model.table_name, field.to_sym, id)
          return true if predicate
        end
      end

      Citation.where(reference: reference).pluck(:id).each do |citation_id|
        references << table_ref(Citation.table_name, :reference_id, citation_id)
        return true if predicate
      end

      nestees.pluck(:id).each do |reference_id|
        references << table_ref('references', :nesting_reference_id, reference_id)
        return true if predicate
      end
      return false if predicate

      references
    end

    private

      attr :references
      attr_reader :reference, :predicate

      delegate :nestees, :id, to: :reference

      def table_ref table, field, id
        { table: table, field: field, id: id }
      end
  end
end
