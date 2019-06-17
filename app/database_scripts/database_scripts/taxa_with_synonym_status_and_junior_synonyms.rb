module DatabaseScripts
  class TaxaWithSynonymStatusAndJuniorSynonyms < DatabaseScript
    def results
      Taxon.where.not(status: Status::SYNONYM).joins(:senior_synonyms).distinct
    end
  end
end

__END__

tags: [new!]
topic_areas: [synonyms]
