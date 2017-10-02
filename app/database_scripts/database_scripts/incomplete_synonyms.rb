module DatabaseScripts
  class IncompleteSynonyms < DatabaseScript
    def results
      Synonym.where(<<-SQL.squish)
        senior_synonym_id IS NULL OR junior_synonym_id IS NULL
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
  `Synonym`s where `junior_synonym_id` or `senior_synonym_id` is blank.
tags: [new!, regression-test]
topic_areas: [synonyms]
