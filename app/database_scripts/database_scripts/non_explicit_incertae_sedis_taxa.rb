# frozen_string_literal: true

module DatabaseScripts
  class NonExplicitIncertaeSedisTaxa < DatabaseScript
    def genera_without_subfamily
      Genus.where(subfamily_id: nil).where(incertae_sedis_in: nil).
        where.not(status: Status::EXCLUDED_FROM_FORMICIDAE)
    end

    def subgenera_without_subfamily
      Subgenus.where(subfamily_id: nil).where(incertae_sedis_in: nil).
        where.not(status: Status::EXCLUDED_FROM_FORMICIDAE)
    end

    def genera_without_tribe
      Genus.where(tribe_id: nil).where(incertae_sedis_in: nil).
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
            taxon_link(taxon),
            taxon.status
          ]
        end
      end <<
        as_table do |t|
          t.caption "Subgenera without subfamily"
          t.header 'Species', 'Status', 'Subfamily of genus'

          t.rows(subgenera_without_subfamily) do |taxon|
            [
              taxon_link(taxon),
              taxon.status,
              taxon_link(taxon.genus.subfamily)
            ]
          end
        end <<
        as_table do |t|
          t.caption "Genera without tribe"
          t.header 'species', 'Status', 'Subfamily'

          t.rows(genera_without_tribe) do |taxon|
            [
              taxon_link(taxon),
              taxon.status,
              taxon_link(taxon.subfamily)
            ]
          end
        end <<
        as_table do |t|
          t.caption "Species without subfamily"
          t.header 'Species', 'Status'

          t.rows(species_without_subfamily) do |taxon|
            [
              taxon_link(taxon),
              taxon.status
            ]
          end
        end
    end
  end
end

__END__

title: Non-explicit <i>incertae sedis</i> taxa

section: main
category: Catalog

description: >
  This list contains taxa that are "_incertae sedis_ by implication" but have no
  value for "Incertae sedis in".


  Taxa that are "Excluded from Formicidae" are not included here.


  Issue: %github453

related_scripts:
  - NonIncertaeSedisTaxaWithoutSubfamily
