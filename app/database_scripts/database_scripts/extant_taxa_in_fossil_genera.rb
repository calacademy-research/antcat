module DatabaseScripts
  class ExtantTaxaInFossilGenera < DatabaseScript
    def results
      Taxon.extant.where(type: ['Species', 'Subspecies']).
        self_join_on(:genus).
        where(taxa_self_join_alias: { fossil: true })
    end

    def render
      as_table do |t|
        t.header :species_or_subspecies, :status, :genus, :genus_status

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
