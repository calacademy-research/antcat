# frozen_string_literal: true

module DatabaseScripts
  class ObsoleteCombinationsWithVeryDifferentEpithets < DatabaseScript
    FALSE_POSITIVES_CURRENT_TAXON_IDS = [
      431926 # "ager agra"
    ]

    def results
      Taxon.where(type: Rank::SPECIES_GROUP_NAMES).obsolete_combinations.joins(:name, current_taxon: :name).
        where(current_taxons_taxa: { type: Rank::SPECIES_GROUP_NAMES }).
        where("SUBSTR(names_taxa.epithet, 1, 3) != SUBSTR(names.epithet, 1, 3)").
        where.not(current_taxon_id: FALSE_POSITIVES_CURRENT_TAXON_IDS).
        includes(:name, current_taxon: :name)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status', 'current_taxon',
          'current_taxon status', 'Taxon epithet', 'current_taxon epithet'

        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.type,
            taxon.status,
            taxon_link(current_taxon),
            current_taxon.status,
            taxon.name.epithet,
            current_taxon.name.epithet
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Catalog
tags: [slow-render]

issue_description: This obsolete combination has a very different epithet compared to its `current_taxon`.

description: >
  "Very different" means that the first three letters in the epithet are not the same.

related_scripts:
  - ProtonymsWithTaxaWithVeryDifferentEpithets
  - ObsoleteCombinationsWithVeryDifferentEpithets
  - ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentTaxonsProtonym
