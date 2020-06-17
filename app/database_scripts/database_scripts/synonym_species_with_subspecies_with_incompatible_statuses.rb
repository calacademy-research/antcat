# frozen_string_literal: true

module DatabaseScripts
  class SynonymSpeciesWithSubspeciesWithIncompatibleStatuses < DatabaseScript
    COMPATIBLE_STATUSES = [
      Status::SYNONYM,
      Status::HOMONYM,
      Status::UNIDENTIFIABLE,
      Status::UNAVAILABLE,
      Status::EXCLUDED_FROM_FORMICIDAE,
      Status::UNAVAILABLE_MISSPELLING,
      Status::UNAVAILABLE_UNCATEGORIZED
    ]

    def results
      Species.where(status: Status::SYNONYM).joins(:subspecies).where.not(subspecies_taxa: { status: COMPATIBLE_STATUSES }).distinct
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Unique subspecies statuses', 'Incompatible subspecies'
        t.rows do |taxon|
          taxa = taxon.subspecies
          incompatible_taxa = taxa.where.not(status: COMPATIBLE_STATUSES)

          [
            taxon_link(taxon),
            taxon.status,
            taxa.pluck(:status).uniq.join(', '),
            taxa_list(incompatible_taxa)
          ]
        end
      end
    end
  end
end

__END__

section: main
category: Catalog
tags: []

issue_description: This species is a synonym with subspecies that have incompatible statuses.

description: >
  Compatible statuses:


  * synonym

  * homonym

  * unidentifiable

  * unavailable

  * excluded from Formicidae

  * unavailable misspelling

  * unavailable uncategorized

related_scripts:
  - SynonymGeneraWithSpeciesWithIncompatibleStatuses
  - SynonymSpeciesWithSubspeciesWithIncompatibleStatuses
