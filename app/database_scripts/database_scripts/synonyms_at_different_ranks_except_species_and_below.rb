# frozen_string_literal: true

module DatabaseScripts
  class SynonymsAtDifferentRanksExceptSpeciesAndBelow < DatabaseScript
    def results
      Taxon.synonyms.
        where(type: Rank::TYPES_ABOVE_SPECIES).
        joins(:current_taxon).where("current_taxons_taxa.type <> taxa.type").
        includes(:current_taxon)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Status', 'CT', 'CT rank', 'CT status'
        t.rows do |taxon|
          current_taxon = taxon.current_taxon

          [
            taxon_link(taxon),
            taxon.type,
            taxon.status,

            taxon_link(current_taxon),
            current_taxon.type,
            current_taxon.status
          ]
        end
      end
    end
  end
end

__END__

title: Synonyms at different ranks (except species and below)

section: research
category: Catalog
tags: [new!]

issue_description:

description: >

related_scripts:
  - SynonymsAtDifferentRanksExceptSpeciesAndBelow
  - SynonymsAtDifferentRanksOnlySpeciesAndBelow
