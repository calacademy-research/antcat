module DatabaseScripts
  class NonExplicitIncertaeSedisTaxa < DatabaseScript
    def genera_without_subfamily
      Genus.where(subfamily_id: nil).where(incertae_sedis_in: nil).
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
        t.header :genus, :status

        t.rows(genera_without_subfamily) do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status
          ]
        end
      end <<
        as_table do |t|
          t.caption "Genera without tribe"
          t.header :species, :status, :subfamily

          t.rows(genera_without_tribe) do |taxon|
            [
              markdown_taxon_link(taxon),
              taxon.status,
              markdown_taxon_link(taxon.subfamily)
            ]
          end
        end <<
        as_table do |t|
          t.caption "Species without subfamily"
          t.header :species, :status

          t.rows(species_without_subfamily) do |taxon|
            [
              markdown_taxon_link(taxon),
              taxon.status
            ]
          end
        end
    end
  end
end

__END__
description: >
  This list contains taxa that are "_incertae sedis_ by implication" but have no
  value for "Incertae sedis in".


  Taxa that are "Excluded from Formicidae" are not included here.

topic_areas: [catalog]
