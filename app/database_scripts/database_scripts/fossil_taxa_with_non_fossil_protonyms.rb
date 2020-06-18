# frozen_string_literal: true

module DatabaseScripts
  class FossilTaxaWithNonFossilProtonyms < DatabaseScript
    def results
      Taxon.fossil.joins(:protonym).where(protonyms: { fossil: false }).includes(:protonym)
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

title: Fossil taxa with non-fossil protonyms

section: regression-test
category: Protonyms
tags: [has-reversed]

issue_description: This taxon is fossil, but its protonym is not.

description: >
  Can be fixed by script if all taxa/protonyms should be changed in the same way.


  This script is the reverse of %dbscript:NonFossilProtonymsWithFossilTaxa

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilTaxaWithFossilProtonyms
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentTaxon
