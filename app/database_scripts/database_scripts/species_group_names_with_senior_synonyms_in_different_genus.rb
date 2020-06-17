# frozen_string_literal: true

module DatabaseScripts
  class SpeciesGroupNamesWithSeniorSynonymsInDifferentGenus < DatabaseScript
    def results
      Taxon.where(type: ['Species', 'Subspecies', 'Infrasubspecies']).
        where(status: Status::SYNONYM).
        joins(:current_valid_taxon).where("current_valid_taxons_taxa.genus_id != taxa.genus_id")
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'current_valid_taxon', 'CVT status'
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            taxon_link(taxon),
            taxon.status,
            taxon_link(current_valid_taxon),
            current_valid_taxon.status
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
