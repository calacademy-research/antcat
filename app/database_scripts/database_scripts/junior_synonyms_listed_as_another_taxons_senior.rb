module DatabaseScripts
  class JuniorSynonymsListedAsAnotherTaxonsSenior < DatabaseScript
    def results
      Taxon.where(id: Synonym.select(:senior_synonym_id)).where(status: Status::SYNONYM)
    end
  end
end

__END__
topic_areas: [synonyms]
tags: [regression-test]
issue_description: This taxon is a junior synonym according to its status, but another taxon shows it as its senior.
