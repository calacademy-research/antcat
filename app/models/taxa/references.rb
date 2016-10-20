# Where "references" refers to something like "items referring to this taxon",
# or "incoming links"; not "academic references".

module Taxa::References
  extend ActiveSupport::Concern

  def references options = {}
    references = []
    references.concat references_in_taxa
    references.concat references_in_taxt unless options[:omit_taxt]
    references.concat references_in_synonyms
  end

  def nontaxt_references
    references omit_taxt: true
  end

  private
    def references_in_taxa
      references = []
      [:subfamily_id, :tribe_id, :genus_id, :subgenus_id,:species_id,
       :homonym_replaced_by_id, :current_valid_taxon_id].each do |field|
        Taxon.where(field => id).each do |taxon|
          references << { table: 'taxa', field: field, id: taxon.id }
        end
      end
      references
    end

    def references_in_synonyms
      references = []
      synonyms_as_senior.each do |synonym|
        references << { table: 'synonyms', field: :senior_synonym_id, id: synonym.junior_synonym_id }
      end
      synonyms_as_junior.each do |synonym|
        references << { table: 'synonyms', field: :junior_synonym_id, id: synonym.senior_synonym_id }
      end
      references
    end

    def references_in_taxt
      references = []
      Taxt.taxt_fields.each do |klass, fields|
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
              references << { table: klass.table_name, field: field, id: record[:id] }
            end
          end
        end
      end
      references
    end
end
