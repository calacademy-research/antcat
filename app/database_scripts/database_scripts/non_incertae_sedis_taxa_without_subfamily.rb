# frozen_string_literal: true

module DatabaseScripts
  class NonIncertaeSedisTaxaWithoutSubfamily < DatabaseScript
    def genera_without_subfamily
      Genus.where(subfamily_id: nil).where(incertae_sedis_in: nil).
        where.not(status: Status::EXCLUDED_FROM_FORMICIDAE)
    end

    def subgenera_without_subfamily
      Subgenus.where(subfamily_id: nil).where(incertae_sedis_in: nil).
        where.not(status: Status::EXCLUDED_FROM_FORMICIDAE)
    end

    def species_without_subfamily
      Species.where(subfamily_id: nil).where(incertae_sedis_in: nil).
        where.not(status: Status::EXCLUDED_FROM_FORMICIDAE)
    end

    def render
      as_table do |t|
        t.caption "Genera without subfamily"
        t.header 'Genus', 'Status'

        t.rows(genera_without_subfamily) do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status
          ]
        end
      end <<
        as_table do |t|
          t.caption "Subgenera without subfamily"
          t.header 'Species', 'Status', 'Subfamily of genus'

          t.rows(subgenera_without_subfamily) do |taxon|
            [
              markdown_taxon_link(taxon),
              taxon.status,
              markdown_taxon_link(taxon.genus.subfamily)
            ]
          end
        end <<
        as_table do |t|
          t.caption "Species without subfamily"
          t.header 'Species', 'Status', 'Genus', 'Subfamily of genus'

          t.rows(species_without_subfamily) do |taxon|
            [
              markdown_taxon_link(taxon),
              taxon.status,
              markdown_taxon_link(taxon.genus),
              markdown_taxon_link(taxon.genus.subfamily)
            ]
          end
        end
    end
  end
end

__END__

title: Non-<i>incertae sedis</i> taxa without subfamily

section: main
category: Catalog
tags: []

description: >
  Note: It may or may not currently be possible to fix all records listed here.


  Taxa that are "Excluded from Formicidae" are not included here.

related_scripts:
  - NonExplicitIncertaeSedisTaxa
