module DatabaseScripts
  class TaxaWithBothJuniorAndSeniorSynonyms < DatabaseScript
    def results
      Taxon.joins(:senior_synonyms, :junior_synonyms)
    end
  end
end

__END__
topic_areas: [synonyms]
tags: [regression-test]
issue_description: This taxon has both senior and junior synonyms.
