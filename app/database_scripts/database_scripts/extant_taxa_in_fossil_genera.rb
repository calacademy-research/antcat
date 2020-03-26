# frozen_string_literal: true

module DatabaseScripts
  class ExtantTaxaInFossilGenera < DatabaseScript
    def results
      SpeciesGroupTaxon.extant.joins(:genus).where(genera_taxa: { fossil: true })
    end

    def render
      as_table do |t|
        t.header 'Species or subspecies', 'Status', 'Genus', 'Genus status'

        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(taxon.genus),
            taxon.genus.status
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [regression-test]

issue_description: The parent of this taxon is fossil, but this taxon is extant.

description: >
  *Prionomyrmex macrops* can be ignored.

related_scripts:
  - ExtantTaxaInFossilGenera
  - ValidTaxaWithNonValidParents
