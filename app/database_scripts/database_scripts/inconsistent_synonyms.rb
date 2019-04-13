module DatabaseScripts
  class InconsistentSynonyms < DatabaseScript
    def results
      Taxon.where(status: Status::SYNONYM).joins(<<~SQL).where("synonyms.id IS NULL")
        LEFT JOIN synonyms
          ON synonyms.junior_synonym_id = taxa.id
          AND synonyms.senior_synonym_id = taxa.current_valid_taxon_id
      SQL
    end

    def render
      as_table do |t|
        t.header :taxon, :current_valid_taxon, :disagreeing_junior_synonym, :disagreeing_senior_synonym
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            markdown_taxon_link(taxon.current_valid_taxon),
            junior_synonyms(taxon),
            senior_synonyms(taxon)
          ]
        end
      end
    end

    private

      def junior_synonyms(taxon)
        link_taxa_ids taxon.junior_synonyms.pluck(:id)
      end

      def senior_synonyms(taxon)
        link_taxa_ids taxon.senior_synonyms.pluck(:id)
      end

      def link_taxa_ids ids
        list = "<ul class='no-bullet'>"
        list << ids.map { |id| "<li>%taxon#{id} - #{Taxon.find(id).status}</li>" }.join
        list << "</ul>"
      end
  end
end

__END__
description: >
  Issue: %github476


  We currently store synonym relationships in two different ways:


  * By using the `status` "synonym" + setting the `current_valid_taxon_id`. This is how we want to represent it.

  * The other is in the `synonyms` table, which can be seen under "Current synonyms" on the edit page.


  If both `Disagreeing junior synonym` and `Disagreeing junior synonym` columns are blank, that means the
  `Current valid taxon` set for `Taxon` is not duplicated in the "Current synonyms" section for `Taxon`.
  I'd say ignore it for now. Adding the `Current valid taxon` in the "Senior synonyms" sections will make `Taxon`
  disappear from this list.

topic_areas: [synonyms]
