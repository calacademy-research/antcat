module DatabaseScripts
  class ValidTaxaWithNonValidParents < DatabaseScript
    def genus_results
      Genus.valid.joins(:subfamily).where.not(subfamilies_taxa: { status: Status::VALID })
    end

    def species_results
      Species.valid.joins(:genus).where.not(genera_taxa: { status: Status::VALID })
    end

    def subspecies_results
      Subspecies.valid.joins(:species).where.not(species_taxa: { status: Status::VALID })
    end

    def render
      as_table do |t|
        t.header :genus, :genus_status, :subfamily, :subfamily_status

        t.rows(genus_results) do |genus|
          [
            markdown_taxon_link(genus),
            genus.status,
            markdown_taxon_link(genus.subfamily),
            genus.subfamily.status
          ]
        end
      end <<
        as_table do |t|
          t.header :species, :species_status, :genus, :genus_status

          t.rows(species_results) do |species|
            [
              markdown_taxon_link(species),
              species.status,
              markdown_taxon_link(species.genus),
              species.genus.status
            ]
          end
        end <<
        as_table do |t|
          t.header :subspecies, :subspecies_status, :species, :species_status

          t.rows(subspecies_results) do |subspecies|
            [
              markdown_taxon_link(subspecies),
              subspecies.status,
              markdown_taxon_link(subspecies.species),
              subspecies.species.status
            ]
          end
        end
    end
  end
end

__END__

title: Valid taxa with non-valid parents
category: Catalog
tags: [regression-test]

description: >

related_scripts:
  - ExtantTaxaInFossilGenera
  - ValidTaxaWithNonValidParents
