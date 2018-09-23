# Where "references" refers to something like "items referring to this taxon",
# or "incoming links"; not "academic references".
# NOTE Expensive method.
# TODO improve.

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
        references = []
        references.concat references_in_taxa
        references.concat references_in_taxt
        references.concat references_in_synonyms
      end
    end

    private

      attr_reader :taxon, :predicate

      delegate :id, :synonyms_as_senior, :synonyms_as_junior, :protonym,
        :protonym_id, to: :taxon

      def any_references?
        Taxon::TAXA_FIELDS_REFERENCING_TAXA.each do |field|
          return true if Taxon.where(field => id).exists?
        end

        return true if synonyms_as_senior.exists? || synonyms_as_junior.exists?

        Taxt.models_with_taxts.each_field do |field, model|
          next unless model.where("#{field} LIKE '%{tax #{taxon.id}}%'").exists? # No refs, next.

          model.where("#{field} LIKE '%{tax #{taxon.id}}%'").pluck(:id).each do |matched_id|
            next if exclude_taxt_match? model, matched_id
            return true
          end
        end

        false
      end

      def references_in_taxa
        references = []
        Taxon::TAXA_FIELDS_REFERENCING_TAXA.each do |field|
          Taxon.where(field => id).pluck(:id).each do |taxon_id|
            references << table_ref('taxa', field, taxon_id)
          end
        end
        references
      end

      def references_in_synonyms
        references = []
        synonyms_as_senior.pluck(:junior_synonym_id).each do |junior_synonym_id|
          references << table_ref('synonyms', :senior_synonym_id, junior_synonym_id)
        end
        synonyms_as_junior.pluck(:senior_synonym_id).each do |senior_synonym_id|
          references << table_ref('synonyms', :junior_synonym_id, senior_synonym_id)
        end
        references
      end

      def references_in_taxt
        references = []
        Taxt.models_with_taxts.each_field do |field, model|
          model.where("#{field} LIKE '%{tax #{taxon.id}}%'").pluck(:id).each do |matched_id|
            next if exclude_taxt_match? model, matched_id
            references << table_ref(model.table_name, field.to_sym, matched_id)
          end
        end
        references
      end

      def exclude_taxt_match? model, matched_id
        return true if model == Taxon && matched_id == id
        return true  if model == Protonym && matched_id == protonym_id
        if model == Citation
          return true if protonym.authorship_id == matched_id
        end
        false
      end

      def table_ref table, field, id
        { table: table, field: field, id: id }
      end
  end
end
