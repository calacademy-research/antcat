module Taxa
  class WhatLinksHere
    include Service

    def initialize taxon, predicate: false
      @taxon = taxon
      @predicate = predicate
    end

    def call
      if predicate
        any_references?
      else
        table_refs = []
        table_refs.concat references_in_taxa
        table_refs.concat references_in_taxt
        table_refs.concat references_in_synonyms
      end
    end

    private

      attr_reader :taxon, :predicate

      delegate :id, :synonyms_as_senior, :synonyms_as_junior, to: :taxon

      def any_references?
        Taxon::TAXA_FIELDS_REFERENCING_TAXA.each do |field|
          return true if Taxon.where(field => id).exists?
        end

        return true if synonyms_as_senior.exists? || synonyms_as_junior.exists?

        Taxt::TAXT_MODELS_AND_FIELDS.each do |(model, field)|
          model.where("#{field} LIKE '%{tax #{taxon.id}}%'").pluck(:id).each do |matched_id|
            next if exclude_taxt_match? model, matched_id
            return true
          end
        end

        false
      end

      def references_in_taxa
        table_refs = []
        Taxon::TAXA_FIELDS_REFERENCING_TAXA.each do |field|
          Taxon.where(field => id).pluck(:id).each do |taxon_id|
            table_refs << table_ref('taxa', field, taxon_id)
          end
        end
        table_refs
      end

      def references_in_synonyms
        table_refs = []
        synonyms_as_senior.pluck(:junior_synonym_id).each do |junior_synonym_id|
          table_refs << table_ref('synonyms', :senior_synonym_id, junior_synonym_id)
        end
        synonyms_as_junior.pluck(:senior_synonym_id).each do |senior_synonym_id|
          table_refs << table_ref('synonyms', :junior_synonym_id, senior_synonym_id)
        end
        table_refs
      end

      def references_in_taxt
        table_refs = []
        Taxt::TAXT_MODELS_AND_FIELDS.each do |(model, field)|
          model.where("#{field} LIKE '%{tax #{taxon.id}}%'").pluck(:id).each do |matched_id|
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
