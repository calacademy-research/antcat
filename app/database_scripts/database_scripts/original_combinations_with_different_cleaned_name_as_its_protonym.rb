# frozen_string_literal: true

module DatabaseScripts
  class OriginalCombinationsWithDifferentCleanedNameAsItsProtonym < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      Taxon.species_group_names.joins(:name, protonym: :name).
        where(original_combination: true).
        where.not("names.cleaned_name = names_protonyms.cleaned_name").
        limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'Taxon (and cleaned name of protonym)', 'Status', 'Protonym'
        t.rows do |taxon|
          protonym = taxon.protonym

          [
            taxon_link(taxon) + "<br>#{protonym.name.cleaned_name}",
            taxon.status,
            protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

section: code-changes-required
tags: [taxa, combinations, names, original-combinations]

issue_description: This species-group taxon has "Original combination" checked, but it does not have the same cleaned name as its protonym.

description: >
  We may have to store original spellings of protonym names to effectively filter out false positives.


  "Original combinations" as is not having the `taxa.original_combination` flag.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - OriginalCombinationsWithDifferentCleanedNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination
