module DatabaseScripts
  class PassThroughNamesWithSynonyms < DatabaseScript
    def results
      Taxon.pass_through_names.left_outer_joins(:junior_synonyms_objects, :senior_synonyms_objects).
        distinct.where("synonyms.senior_synonym_id IS NOT NULL OR synonyms.junior_synonym_id IS NOT NULL")
    end
  end
end

__END__
description: >
  Original combinations, obsolete combination and unavailable misspellings with synonyms.


  See also [Pass through names with taxts](/database_scripts/pass_through_names_with_taxts).


  See %github375.

tags: [regression-test]
topic_areas: [synonyms]
issue_description: This taxon is a "pass-through name", but is has senior or junior synonyms.
