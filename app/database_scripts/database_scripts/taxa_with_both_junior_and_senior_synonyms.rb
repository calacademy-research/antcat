module DatabaseScripts
  class TaxaWithBothJuniorAndSeniorSynonyms < DatabaseScript
    def results
      Taxon.joins(:senior_synonyms, :junior_synonyms)
    end
  end
end

__END__
description: See %github279.
topic_areas: [synonyms]
issue_description: This taxon has both senior and junior synonyms.
