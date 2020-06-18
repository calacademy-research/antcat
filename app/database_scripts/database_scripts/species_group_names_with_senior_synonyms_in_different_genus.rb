# frozen_string_literal: true

module DatabaseScripts
  class SpeciesGroupNamesWithSeniorSynonymsInDifferentGenus < DatabaseScript
    def results
      Taxon.where(type: ['Species', 'Subspecies', 'Infrasubspecies']).
        where(status: Status::SYNONYM).
        joins(:current_taxon).where("current_taxons_taxa.genus_id != taxa.genus_id")
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'current_taxon', 'CT status'
        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.status,
            taxon_link(current_taxon),
            current_taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: Species-group names with senior synonyms in different genus

section: main
category: Catalog
tags: [new!]

issue_description:

description: >
  "Species-group names" as is in where `taxa.type` is one of `Species`, `Subspecies` or `Infrasubspecies`.

related_scripts:
  - SpeciesGroupNamesWithSeniorSynonymsInDifferentGenus
