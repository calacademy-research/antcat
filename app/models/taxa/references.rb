# Where "references" refers to something like "items referring to this taxon",
# or "incoming links"; not "academic references".

module Taxa::References
  extend ActiveSupport::Concern

  TAXA_FIELDS_REFERENCING_TAXA = [:subfamily_id, :tribe_id, :genus_id, :subgenus_id,
    :species_id, :homonym_replaced_by_id, :current_valid_taxon_id]

  def references omit_taxt: false
    references = []
    references.concat references_in_taxa
    references.concat references_in_taxt unless omit_taxt
    references.concat references_in_synonyms
  end

  # TODO not used (December 2016).
  def nontaxt_references
    references omit_taxt: true
  end

  def any_nontaxt_references?
    return true if any_references_in_taxa?
    references_in_synonyms.present? # Less important, not optimized.
  end

  private
    def any_references_in_taxa?
      TAXA_FIELDS_REFERENCING_TAXA.each do |field|
        return true if Taxon.where(field => id).exists?
      end
      false
    end

    def references_in_taxa
      references = []
      TAXA_FIELDS_REFERENCING_TAXA.each do |field|
        Taxon.where(field => id).each do |taxon|
          references << table_ref('taxa', field, taxon.id)
        end
      end
      references
    end

    def references_in_synonyms
      references = []
      synonyms_as_senior.each do |synonym|
        references << table_ref('synonyms', :senior_synonym_id, synonym.junior_synonym_id)
      end
      synonyms_as_junior.each do |synonym|
        references << table_ref('synonyms', :junior_synonym_id, synonym.senior_synonym_id)
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
