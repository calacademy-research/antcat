# frozen_string_literal: true

module DatabaseScripts
  class ObsoleteCombinationsWithObsoleteCombinations < DatabaseScript
    def results
      Taxon.obsolete_combinations.joins(:obsolete_combinations)
    end

    def render
      as_table do |t|
        t.header 'Obsolete combination', 'Obsolete combinations of obsolete combination'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon_links(taxon.obsolete_combinations)
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Catalog
tags: [has-reversed]

issue_description: This taxon has obsolete combinations, but it is itself an obsolete combination.

description: >
  The right column lists taxa with the status `obsolete combination` where the `current_taxon`
  is set to another obsolete combination (left column).


  To **Quick-fix**, see the reversed script.


  This script is the reverse of %dbscript:ObsoleteCombinationsWithCurrentTaxonsThatAreAlsoObsoleteCombinations

related_scripts:
  - ObsoleteCombinationsWithObsoleteCombinations
