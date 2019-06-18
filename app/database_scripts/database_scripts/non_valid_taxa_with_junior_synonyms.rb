module DatabaseScripts
  class NonValidTaxaWithJuniorSynonyms < DatabaseScript
    def results
      Taxon.where(id: Synonym.select(:senior_synonym_id)).where.not(status: Status::VALID)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :junior_synonyms
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.junior_synonyms.map { |junior| junior.decorate.link_to_taxon }.join('<br>')
          ]
        end
      end
    end
  end
end

__END__

description: >
  Collective group names in this list are not necessarily incorrect.

tags: [new!]
topic_areas: [synonyms]
