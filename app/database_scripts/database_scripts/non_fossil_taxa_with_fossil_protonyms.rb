# frozen_string_literal: true

module DatabaseScripts
  class NonFossilTaxaWithFossilProtonyms < DatabaseScript
    def results
      Taxon.extant.joins(:protonym).where(protonyms: { fossil: true }).includes(:protonym)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Protonym', 'Locality'
        t.rows do |taxon|
          protonym = taxon.protonym

          [
            taxon_link(taxon),
            taxon.status,
            protonym.decorate.link_to_protonym,
            protonym.locality
          ]
        end
      end
    end
  end
end

__END__

title: Non-fossil taxa with fossil protonyms

section: regression-test
category: Protonyms
tags: [has-reversed]

issue_description: This taxon is not fossil, but its protonym is fossil.

description: >
  This is not necessarily incorrect.


  Can be fixed by script if all taxa/protonyms should be changed in the same way.


  This script is the reverse of %dbscript:FossilProtonymsWithNonFossilTaxa

related_scripts:
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentTaxon
