module DatabaseScripts
  class PassThroughNamesWithTaxts < DatabaseScript
    def results
      Taxon.pass_through_names.left_outer_joins(:history_items, :reference_sections).
        distinct.where("taxon_history_items.id IS NOT NULL OR reference_sections.id IS NOT NULL")
    end
  end
end

__END__

title: Pass-through names with taxts
category: Synonyms
tags: [regression-test]

issue_description: This taxon is a "pass-through name", but is has history items or reference sections.

description: >
  Obsolete combination and unavailable misspellings with
  history items or reference sections.


  See %github375.
