module DatabaseScripts
  class NonFossilTaxaWithFossilProtonyms < DatabaseScript
    def results
      Taxon.extant.joins(:protonym).where(protonyms: { fossil: true }).includes(:protonym)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :protonym, :locality
        t.rows do |taxon|
          protonym = taxon.protonym

          [
            markdown_taxon_link(taxon),
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
category: Protonyms
tags: [regression-test]

issue_description: This taxon is not fossil, but its protonym is fossil.

description: >
  This is not necessarily incorrect.


  Can be fixed by script if all taxa/protonyms should be changed in the same way.


  This script is the reverse of %dbscript:FossilProtonymsWithNonFossilTaxa

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentValidTaxon
