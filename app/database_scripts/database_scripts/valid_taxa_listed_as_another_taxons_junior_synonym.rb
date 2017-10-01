module DatabaseScripts
  class ValidTaxaListedAsAnotherTaxonsJuniorSynonym < DatabaseScript
    def results
      Taxon.where(id: Synonym.pluck(:junior_synonym_id)).where(status: "valid")
    end
  end
end

__END__
description: See %github279.
tags: [new!]
topic_areas: [synonyms]
