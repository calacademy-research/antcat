module DatabaseScripts
  class ObsoleteCombinationsWithObsoleteCombinations < DatabaseScript
    def results
      Taxon.obsolete_combinations.joins(:obsolete_combinations)
    end

    def render
      as_table do |t|
        t.header :obsolete_combination, :obsolete_combinations_of_obsolete_combination
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.obsolete_combinations.map(&:link_to_taxon).join('<br>')
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [new!]

issue_description: This taxon has obsolete combinations, but it is itself an obsolete combination.

description: >
  The right column lists taxa with the status `obsolete combination` where the `current_valid_taxon`
  is set to another obsolete combination (left column).
