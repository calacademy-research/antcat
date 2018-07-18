module DatabaseScripts
  class TaxaWithMoreThanOneSeniorSynonym < DatabaseScript
    def results
      Taxon.where(id: synonym_records_with_more_than_one_senior)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :senior_synonyms_count
        t.rows do |taxon|
          [markdown_taxon_link(taxon), taxon.status, taxon.senior_synonyms.count]
        end
      end
    end

    private

      def synonym_records_with_more_than_one_senior
        Synonym.group(:junior_synonym_id).
          having('COUNT(synonyms.senior_synonym_id) > 1').
          pluck(:junior_synonym_id)
      end
  end
end

__END__
description: >
  If the senior synonyms count is different from the number of senior synonyms listed
  in synonyms section on the edit page, that may have to do with
  [Synonym records referencing non existent taxa](/database_scripts/synonym_records_referencing_non_existent_taxa).
topic_areas: [synonyms]
