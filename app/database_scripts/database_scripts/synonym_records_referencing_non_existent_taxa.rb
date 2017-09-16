module DatabaseScripts
  class SynonymRecordsReferencingNonExistentTaxa < DatabaseScript
    def results
      Synonym.where(<<-SQL.squish)
        senior_synonym_id NOT IN (SELECT DISTINCT(id) FROM taxa)
          OR junior_synonym_id NOT IN (SELECT DISTINCT(id) FROM taxa)
      SQL
    end

    def render
      as_table do |t|
        t.header :synonym_id, :junior_synonym, :senior_synonym

        t.rows do |synonym|
          [
            synonym_link(synonym),
            markdown_taxon_link(synonym.junior_synonym),
            markdown_taxon_link(synonym.senior_synonym)
          ]
        end
      end
    end
  end
end

__END__
description: >
  `Synonym` records where `.senior_synonym_id` or
  `junior_synonym_id` refers to a non-existent taxon.

topic_areas: [synonyms]
