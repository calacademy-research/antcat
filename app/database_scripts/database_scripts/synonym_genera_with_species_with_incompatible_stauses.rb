module DatabaseScripts
  class SynonymGeneraWithSpeciesWithIncompatibleStauses < DatabaseScript
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
      Genus.where(status: Status::SYNONYM).joins(:species).where.not(species_taxa: { status: COMPATIBLE_STATUSES }).distinct.
        includes(:name)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :unique_species_statuses, :incompatible_species
        t.rows do |taxon|
          taxa = taxon.species
          incompatible_taxa = taxa.where.not(status: COMPATIBLE_STATUSES).includes(:name)

          [
            markdown_taxon_link(taxon),
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

category: Catalog
tags: [new!]

issue_description: This genus is a synonym with species that have incompatible statuses.

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
  - SynonymGeneraWithSpeciesWithIncompatibleStauses
  - SynonymSpeciesWithSubspeciesWithIncompatibleStauses
