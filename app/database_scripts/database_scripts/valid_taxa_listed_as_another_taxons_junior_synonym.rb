module DatabaseScripts
  class ValidTaxaListedAsAnotherTaxonsJuniorSynonym < DatabaseScript
    def results
      Taxon.where(id: Synonym.select(:junior_synonym_id)).valid
    end
  end
end

__END__
description: See %github279.
tags: [regression-test]
topic_areas: [synonyms]
