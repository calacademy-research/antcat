# Where "references" refers to something like "items referring to this taxon",
# or "incoming links"; not "academic references".
# NOTE Expensive method.
# TODO improve.

module Taxa
  class WhatLinksHere
    include Service

    def initialize taxon, omit_taxt: false
      @taxon = taxon
      @omit_taxt = omit_taxt
    end

    def call
      references = []
      references.concat references_in_taxa
      references.concat references_in_taxt unless omit_taxt
      references.concat references_in_synonyms
    end

    private
      attr_reader :taxon, :omit_taxt

      delegate :id, :synonyms_as_senior, :synonyms_as_junior, :protonym,
        :protonym_id, to: :taxon

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
          authorship_id = protonym.try(:authorship).try(:id)
          return true if authorship_id == matched_id
        end
        false
      end

      def table_ref table, field, id
        { table: table, field: field, id: id }
      end
    end
end
