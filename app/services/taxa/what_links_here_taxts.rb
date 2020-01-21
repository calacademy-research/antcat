module Taxa
  class WhatLinksHereTaxts
    include Service

    def initialize taxon, predicate: false
      @taxon = taxon
      @predicate = predicate
    end

    def call
      if predicate
        any_table_refs?
      else
        table_refs
      end
    end

    private

      attr_reader :taxon, :predicate

      delegate :id, to: :taxon

      def any_table_refs?
        Taxt::TAXTABLES.each do |(model, _table, field)|
          model.where("#{field} REGEXP ?", "{(tax|taxac) #{taxon.id}}").pluck(:id).each do |matched_id|
            next if exclude_taxt_match? model, matched_id
            return true
          end
        end

        false
      end

      def table_refs
        table_refs = []
        Taxt::TAXTABLES.each do |(model, _table, field)|
          model.where("#{field} REGEXP ?", "{(tax|taxac) #{taxon.id}}").pluck(:id).each do |matched_id|
            next if exclude_taxt_match? model, matched_id
            table_refs << table_ref(model.table_name, field.to_sym, matched_id)
          end
        end
        table_refs
      end

      def exclude_taxt_match? model, matched_id
        return true if model == Taxon && matched_id == id
        false
      end

      def table_ref table, field, id
        TableRef.new(table, field, id)
      end
  end
end
