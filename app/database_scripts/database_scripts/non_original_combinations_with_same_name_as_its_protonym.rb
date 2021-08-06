# frozen_string_literal: true

module DatabaseScripts
  class NonOriginalCombinationsWithSameNameAsItsProtonym < DatabaseScript
    LIMIT = 500

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def results
      Taxon.species_group_names.joins(:name, protonym: :name).
        where.not(original_combination: true).
        where("names.cleaned_name = names_protonyms.cleaned_name").
        limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Protonym', 'Protonym already has an original combination?'
        t.rows do |taxon|
          original_combination = taxon.protonym.original_combination

          [
            taxon_link(taxon),
            taxon.status,
            taxon.protonym.decorate.link_to_protonym,
            (original_combination ? bold_warning('Yes: ') + taxon_link(original_combination) : bold_notice('No'))
          ]
        end
      end
    end
  end
end

__END__

title: Non-original combinations with same name as its protonym

section: regression-test
tags: [taxa, names, combinations, original-combinations]

issue_description: This species-group taxon has the same cleaned name as its protonym, but "Original combination" is not checked.

description: >
  "Non-original combinations" as is not having the `taxa.original_combination` flag.


  Can be updated by script (see %github1091).

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - OriginalCombinationsWithDifferentCleanedNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination
