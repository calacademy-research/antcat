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
        Taxt::TAXT_FIELDS.each do |klass, fields|
          klass.send(:all).each do |record|
            # don't include the taxt in this or child records
            next if klass == Taxon && record.id == id
            next if klass == Protonym && record.id == protonym_id
            if klass == Citation
              authorship_id = protonym.try(:authorship).try(:id)
              next if authorship_id == record.id
            end
            fields.each do |field|
              next unless record[field]
              if record[field] =~ /{tax #{id}}/
                references << table_ref(klass.table_name, field, record.id)
              end
            end
          end
        end
        references
      end

      def table_ref table, field, id
        { table: table, field: field, id: id }
      end
    end
end
