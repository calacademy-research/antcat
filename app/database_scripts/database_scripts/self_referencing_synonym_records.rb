module DatabaseScripts
  class SelfReferencingSynonymRecords < DatabaseScript
    def results
      Synonym.where(table[:senior_synonym_id].eq(table[:junior_synonym_id]))
    end

    def render
      as_table do
        header :synonym_id, :junior_and_senior_synonym
        rows do |synonym|
          taxon = synonym.junior_synonym
          [ synonym_link(synonym), markdown_taxon_link(taxon)]
        end
      end
    end

    private
      def table
        Synonym.arel_table
      end
  end
end

__END__
description: >
  Self-referencing `Synonym` records, that is, where `.senior_synonym_id` and
  `junior_synonym_id` refer to the same taxon.
tags: [new!]
topic_areas: [synonyms]
