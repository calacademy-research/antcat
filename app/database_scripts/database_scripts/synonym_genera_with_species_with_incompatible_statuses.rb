# frozen_string_literal: true

module DatabaseScripts
  class SynonymGeneraWithSpeciesWithIncompatibleStatuses < DatabaseScript
    COMPATIBLE_STATUSES = [
      Status::SYNONYM,
      Status::HOMONYM,
      Status::OBSOLETE_COMBINATION,
      Status::UNIDENTIFIABLE,
      Status::UNAVAILABLE,
      Status::EXCLUDED_FROM_FORMICIDAE,
      Status::UNAVAILABLE_MISSPELLING
    ]

    def results
      Genus.synonyms.joins(:species).where.not(species_taxa: { status: COMPATIBLE_STATUSES }).distinct.
        includes(:name)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Unique species statuses', 'Incompatible species'
        t.rows do |taxon|
          taxa = taxon.species
          incompatible_taxa = taxa.where.not(status: COMPATIBLE_STATUSES).includes(:name)

          [
            taxon_link(taxon),
            taxon.status,
            taxa.pluck(:status).uniq.join(', '),
            taxon_links(incompatible_taxa)
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
tags: [taxa, synonyms]

issue_description: This genus is a synonym with species that have incompatible statuses.

description: >
  Compatible statuses:


  * `synonym`

  * `homonym`

  * `obsolete combination`

  * `unidentifiable`

  * `unavailable`

  * `excluded from Formicidae`

  * `unavailable misspelling`

related_scripts:
  - SynonymGeneraWithSpeciesWithIncompatibleStatuses
  - SynonymSpeciesWithSubspeciesWithIncompatibleStatuses
