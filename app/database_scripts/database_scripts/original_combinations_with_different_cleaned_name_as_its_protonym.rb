# frozen_string_literal: true

module DatabaseScripts
  class OriginalCombinationsWithDifferentCleanedNameAsItsProtonym < DatabaseScript
    LIMIT = 500

    def results
      Taxon.where(type: Rank::SPECIES_GROUP_NAMES).joins(:name, protonym: :name).
        where(original_combination: true).
        where.not("names.cleaned_name = names_protonyms.cleaned_name").
        limit(LIMIT)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Protonym'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.status,
            taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

section: code-changes-required
category: Catalog
tags: []

issue_description: This species-group taxon has "Original combination" checked, but it does not have the same cleaned name as its protonym.

description: >
  We may have to store original spellings of protonym names to effectively filter out false positives.


  "Original combinations" as is not having the `taxa.original_combination` flag.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - OriginalCombinationsWithDifferentCleanedNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination
