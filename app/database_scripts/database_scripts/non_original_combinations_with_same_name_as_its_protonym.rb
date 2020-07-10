# frozen_string_literal: true

module DatabaseScripts
  class NonOriginalCombinationsWithSameNameAsItsProtonym < DatabaseScript
    LIMIT = 500

    def results
      Taxon.where(type: Rank::SPECIES_GROUP_NAME_TYPES).joins(:name, protonym: :name).
        where.not(original_combination: true).
        where("names.cleaned_name = names_protonyms.cleaned_name").
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

title: Non-original combinations with same name as its protonym

section: regression-test
category: Catalog
tags: []

issue_description: This species-group taxon has the same name as its protonym, but "Original combination" is not checked.

description: >
  **This script can be ignored**, since we do not rely on this data point at the moment, and the flag can be updated by script.
  It may become more relevant in the future.


  "Non-original combinations" as is not having the `taxa.original_combination` flag.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination
