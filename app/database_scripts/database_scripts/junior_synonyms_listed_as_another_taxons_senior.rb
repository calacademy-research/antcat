module DatabaseScripts
  class JuniorSynonymsListedAsAnotherTaxonsSenior < DatabaseScript
    def results
      Taxon.where(id: Synonym.select(:senior_synonym_id)).where(status: Status::SYNONYM)
    end
  end
end

__END__
description: See %github279.
tags: [regression-test]
topic_areas: [synonyms]
issue_description: This taxon is a junior synonym according to its status, but another taxon shows it as its senior.
