module DatabaseScripts
  class PassThroughNamesWithSynonyms < DatabaseScript
    def results
      with_senior_synonyms + with_junior_synonyms
    end

    private

      def with_senior_synonyms
        Taxon.pass_through_names.joins(:senior_synonyms).distinct
      end

      def with_junior_synonyms
        Taxon.pass_through_names.joins(:junior_synonyms).distinct
      end
  end
end

__END__
description: >
  Original combinations, obsolete combination and unavailable misspellings with synonyms.


  See also [Pass through names with taxts](/database_scripts/pass_through_names_with_taxts).


  See %github375.

topic_areas: [synonyms]
