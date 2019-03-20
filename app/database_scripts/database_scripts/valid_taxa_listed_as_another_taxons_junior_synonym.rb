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
issue_description: This taxon has the status 'valid', but it also has senior synonym(s).
