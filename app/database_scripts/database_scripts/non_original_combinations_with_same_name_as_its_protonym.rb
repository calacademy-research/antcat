# frozen_string_literal: true

module DatabaseScripts
  class NonOriginalCombinationsWithSameNameAsItsProtonym < DatabaseScript
    def results
      Taxon.joins(:name, protonym: :name).
        obsolete_combinations.
        where.not(original_combination: true).
        where("names.name = names_protonyms.name")
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

issue_description: This obsolete combination has the same name as its protonym, but "Original combination" is not checked.

description: >
  **This script can be ignored**, since we do not rely on this data point at the moment, and the flag can be updated by script.
  It may become more relevant in the future.


  "Non-original combinations" as is not having the `taxa.original_combination` flag.
  Only taxa with the status `obsolete combination` are included here.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination
