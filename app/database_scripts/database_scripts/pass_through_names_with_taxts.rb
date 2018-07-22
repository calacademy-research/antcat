module DatabaseScripts
  class PassThroughNamesWithTaxts < DatabaseScript
    def results
      with_history_items + with_reference_sections
    end

    private

      def with_history_items
        Taxon.pass_through_names.joins(:history_items).distinct
      end

      def with_reference_sections
        Taxon.pass_through_names.joins(:reference_sections).distinct
      end
  end
end

__END__
description: >
  Original combinations, obsolete combination and unavailable misspellings with
  history items or reference sections.


  See also [Pass through names with synonyms](/database_scripts/pass_through_names_with_synonyms).


  See %github375.

tags: [new!]
topic_areas: [synonyms]
