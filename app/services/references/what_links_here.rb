# References to a reference.
# NOTE Expensive method.

module References
  class WhatLinksHere
    def initialize reference, return_true_or_false: false
      @reference = reference
      @return_early = return_true_or_false
      @references = []
    end

    def call
      Taxt::TAXT_FIELDS.each do |klass, fields|
        klass.send(:all).find_each do |record|
          fields.each do |field|
            next unless record[field]
            if record[field] =~ /{ref #{id}}/
              references << table_ref(klass.table_name, field, record.id)
              return true if return_early
            end
          end
        end
      end

      Citation.where(reference: reference).find_each do |record|
        references << table_ref(Citation.table_name, :reference_id, record.id)
        return true if return_early
      end

      nestees.find_each do |record|
        references << table_ref('references', :nesting_reference_id, record.id)
        return true if return_early
      end
      return false if return_early

      references
    end

    private
      attr :references
      attr_reader :reference, :return_early

      delegate :nestees, :id, to: :reference

      def table_ref table, field, id
        { table: table, field: field, id: id }
      end
  end
end
