module DatabaseScripts
  class JuniorSynonymsListedAsAnotherTaxonsSenior < DatabaseScript
    def results
      Taxon.where(id: Synonym.pluck(:senior_synonym_id)).where(status: "synonym")
    end
  end
end

__END__
description: See %github279.
tags: [new!]
topic_areas: [synonyms]
