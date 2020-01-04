module DatabaseScripts
  class NonFossilTaxaWithFossilProtonyms < DatabaseScript
    def results
      Taxon.extant.joins(:protonym).where(protonyms: { fossil: true }).includes(:protonym)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :protonym
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            taxon.protonym.decorate.link_to_protonym
          ]
        end
      end
    end
  end
end

__END__

title: Non-fossil taxa with fossil protonyms
category: Protonyms

issue_description: This taxon is not fossil, but its protonym is fossil.

description: >
  This is not necessarily incorrect.


  This script is the reverse of %dbscript:NonFossilTaxaWithFossilProtonyms

related_scripts:
  - FossilProtonymsWithNonFossilTaxa
  - FossilTaxaWithNonFossilProtonyms
  - NonFossilProtonymsWithFossilTaxa
  - NonFossilTaxaWithFossilProtonyms
  - ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentValidTaxon
